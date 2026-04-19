--[[
    MainServer
    Script principal del servidor - Loop de juego y coordinación
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Cargar módulos
local Utility = require(ReplicatedStorage.Modules.Utility)
local SaveManager = require(ReplicatedStorage.Modules.SaveManager)

-- Configuración
local CONFIG = {
    AUTO_SAVE_INTERVAL = 300,  -- 5 minutos
    MAX_PLAYERS = 20,
    SERVER_TICK_RATE = 1/30,   -- 30 TPS
}

-- Estado del servidor
local Server = {
    startTime = 0,
    players = {},
    zoneState = {},
    bossState = {},
    isRunning = false,
}

-- Inicializar servidor
function Server.init()
    Utility.log("MainServer", "Iniciando servidor...")

    -- Cargar módulos necesarios
    Server.loadModules()

    -- Configurar eventos de jugadores
    Server.setupPlayerEvents()

    -- Iniciar loop principal
    Server.isRunning = true
    Server.startTime = os.time()

    -- Loop principal
    task.spawn(function()
        while Server.isRunning do
            Server.update()
            task.wait(CONFIG.SERVER_TICK_RATE)
        end
    end)

    -- Auto-guardado periódico
    task.spawn(function()
        while Server.isRunning do
            task.wait(CONFIG.AUTO_SAVE_INTERVAL)
            Server.autoSave()
        end
    end)

    Utility.log("MainServer", "Servidor iniciado correctamente")
end

-- Cargar módulos requeridos
function Server.loadModules()
    -- Verificar que SaveManager esté cargado
    if not SaveManager then
        Utility.error("MainServer", "SaveManager no cargado correctamente")
    end

    -- Cargar y inicializar Remotes
    local Remotes = require(ReplicatedStorage.Remotes.Remotes)
    Remotes.init()

    -- Cargar RemoteHandler
    local RemoteHandler = require(ServerScriptService.Servers.RemoteHandler)
    RemoteHandler.init()

    Utility.log("MainServer", "Módulos cargados")
end

-- Configurar eventos de jugadores
function Server.setupPlayerEvents()
    Players.PlayerAdded:Connect(function(player)
        Server.onPlayerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        Server.onPlayerRemoving(player)
    end)

    game.BindToClose:Connect(function()
        Server.onServerClose()
    end)
end

-- Jugador se une
function Server.onPlayerAdded(player)
    Utility.log("MainServer", "Jugador conectado: " .. player.Name)

    -- Verificar límite de jugadores
    if #Players:GetPlayers() >= CONFIG.MAX_PLAYERS then
        player:Kick("Servidor lleno")
        return
    end

    -- Inicializar datos del jugador
    local success, data = SaveManager.loadPlayerData(player)
    if not success then
        Utility.warn("MainServer", "No se pudo cargar datos de " .. player.Name .. ", creando nuevos")
        data = SaveManager.createDefaultData(player)
    end

    Server.players[player.UserId] = {
        player = player,
        data = data,
        joinTime = os.time(),
        currentZone = data.currentZone or 1,
    }

    -- Spawnear jugador
    Server.spawnPlayer(player)
end

-- Jugador se va
function Server.onPlayerRemoving(player)
    Utility.log("MainServer", "Jugador desconectado: " .. player.Name)

    local playerData = Server.players[player.UserId]
    if playerData then
        -- Guardar datos antes de salir
        SaveManager.savePlayerData(player, playerData.data)
        Server.players[player.UserId] = nil
    end
end

-- Spawnear jugador en zona inicial
function Server.spawnPlayer(player)
    local playerData = Server.players[player.UserId]
    local startZone = playerData.data.currentZone or 1

    -- Encontrar spawn point de la zona
    local zoneFolder = workspace.Zones:FindFirstChild("Zone" .. startZone)
    local spawnPoint = nil

    if zoneFolder then
        spawnPoint = zoneFolder:FindFirstChild("SpawnPoint")
    end

    if not spawnPoint then
        spawnPoint = workspace:FindFirstChild("DefaultSpawn")
    end

    if spawnPoint then
        player.Character:SetPrimaryPartCFrame(spawnPoint.CFrame)
    end

    Utility.log("MainServer", "Jugador spawnado en Zona " .. startZone)
end

-- Auto-guardado
function Server.autoSave()
    Utility.log("MainServer", "Auto-guardado...")

    for userId, playerData in pairs(Server.players) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            SaveManager.savePlayerData(player, playerData.data)
        end
    end

    Utility.log("MainServer", "Auto-guardado completado")
end

-- Update loop (30 TPS)
function Server.update()
    -- Actualizar estado de zonas
    Server.updateZones()

    -- Actualizar estado de jefes
    Server.updateBosses()

    -- Actualizar jugadores
    for userId, playerData in pairs(Server.players) do
        Server.updatePlayer(playerData)
    end
end

-- Actualizar zonas
function Server.updateZones()
    for zoneId, state in pairs(Server.zoneState) do
        -- Lógica específica por zona
        -- Spawning de enemigos, eventos, etc.
    end
end

-- Actualizar jefes
function Server.updateBosses()
    for bossId, state in pairs(Server.bossState) do
        if state.active then
            -- Lógica del jefe
        end
    end
end

-- Actualizar jugador individual
function Server.updatePlayer(playerData)
    local player = playerData.player
    local character = player.Character

    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Actualizar tiempo de juego
    playerData.data.playTime = (playerData.data.playTime or 0) + CONFIG.SERVER_TICK_RATE

    -- Actualizar zona actual
    local rootPart = character.HumanoidRootPart
    for i = 1, 6 do
        local zone = workspace.Zones:FindFirstChild("Zone" .. i)
        if zone and zone:FindFirstChild("ZoneTrigger") then
            local trigger = zone.ZoneTrigger
            local bounds = trigger:GetExtentsSize()
            local center = trigger.CFrame.Position

            if math.abs(rootPart.Position.X - center.X) < bounds.X / 2 and
               math.abs(rootPart.Position.Z - center.Z) < bounds.Z / 2 then
                if playerData.currentZone ~= i then
                    Server.onPlayerEnterZone(player, i)
                end
            end
        end
    end
end

-- Jugador entra a nueva zona
function Server.onPlayerEnterZone(player, zoneId)
    local playerData = Server.players[player.UserId]
    if not playerData then return end

    local oldZone = playerData.currentZone
    playerData.currentZone = zoneId
    playerData.data.currentZone = zoneId

    Utility.log("MainServer", player.Name .. " entró a Zona " .. zoneId)

    -- Trigger evento de zona
    local ZoneEvent = ReplicatedStorage:FindFirstChild("ZoneEvent")
    if ZoneEvent then
        ZoneEvent:FireClient(player, "onZoneEnter", zoneId)
    end

    -- Guardar progreso de zona
    if zoneId > oldZone then
        table.insert(playerData.data.zonesCompleted or {}, zoneId)
    end
end

-- Cierre del servidor
function Server.onServerClose()
    Utility.log("MainServer", "Servidor cerrándose...")

    -- Guardar todos los jugadores
    for userId, playerData in pairs(Server.players) do
        SaveManager.savePlayerData(playerData.player, playerData.data)
    end

    Server.isRunning = false
end

-- Obtener estadísticas del servidor
function Server.getStats()
    return {
        uptime = os.time() - Server.startTime,
        playerCount = #Server.players,
        zoneState = Server.zoneState,
        bossState = Server.bossState,
    }
end

-- Iniciar
task.spawn(function()
    task.wait(1)  -- Esperar a que todo cargue
    Server.init()
end)

return Server
