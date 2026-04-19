--[[
    EnemySpawner
    Spawn dinámico de infectados por zona
    Control de densidad y optimización
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = require(ReplicatedStorage.Modules.Utility)
local EnemyAI = require(ReplicatedStorage.Modules.EnemyAI)

-- Configuración
local CONFIG = {
    -- Densidad de enemigos por zona
    DENSITY = {
        Zone1 = 5,    -- Tutorial, pocos enemigos
        Zone2 = 15,   -- Mall, grupos medianos
        Zone3 = 20,   -- Policía, más densidad
        Zone4 = 25,   -- Hospital, máxima densidad
        Zone5 = 12,   -- Bosque, dispersos
        Zone6 = 18,   -- Punto Cero, élite
    },

    -- Tipos de enemigos por zona
    TYPES = {
        Zone1 = {"Common"},
        Zone2 = {"Common", "Common", "Corredor"},
        Zone3 = {"Common", "Corredor", "Blindado"},
        Zone4 = {"Common", "Corredor", "Blindado", "Acechador"},
        Zone5 = {"Common", "Corredor", "Acechador"},
        Zone6 = {"Common", "Corredor", "Blindado", "Acechador"},
    },

    -- Spawn points por zona
    SPAWN_POINTS = {},

    -- Máximo de enemigos activos
    MAX_ACTIVE = 30,

    -- Distancia de spawn desde el jugador
    SPAWN_DISTANCE = {min = 20, max = 50},

    -- Tiempo entre spawns
    SPAWN_INTERVAL = 10,
}

-- Estado
local Spawner = {
    activeEnemies = {},
    zoneState = {},
    isRunning = false,
}

-- Inicializar
function Spawner.init()
    Utility.log("EnemySpawner", "Iniciando...")

    -- Cargar spawn points desde Workspace
    Spawner.loadSpawnPoints()

    -- Iniciar loop de spawn
    Spawner.isRunning = true
    task.spawn(function()
        while Spawner.isRunning do
            Spawner.update()
            task.wait(CONFIG.SPAWN_INTERVAL)
        end
    end)

    Utility.log("EnemySpawner", "Iniciado correctamente")
end

-- Cargar spawn points
function Spawner.loadSpawnPoints()
    local zonesFolder = workspace:FindFirstChild("Zones")
    if not zonesFolder then return end

    for i = 1, 6 do
        local zone = zonesFolder:FindFirstChild("Zone" .. i)
        if zone then
            local spawnFolder = zone:FindFirstChild("SpawnPoints")
            if spawnFolder then
                CONFIG.SPAWN_POINTS["Zone" .. i] = spawnFolder:GetChildren()
            end
        end
    end

    Utility.log("EnemySpawner", "Spawn points cargados: " .. tostring(#CONFIG.SPAWN_POINTS))
end

-- Actualizar (llamado periódicamente)
function Spawner.update()
    -- Limpiar enemigos muertos
    Spawner.cleanupDeadEnemies()

    -- Verificar límite
    if #Spawner.activeEnemies >= CONFIG.MAX_ACTIVE then
        return
    end

    -- Spawnear nuevos enemigos
    for _, player in ipairs(Players:GetPlayers()) do
        Spawner.spawnForPlayer(player)
    end
end

-- Spawnear enemigos cerca de un jugador
function Spawner.spawnForPlayer(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local playerPos = character.HumanoidRootPart.Position
    local zoneId = Spawner.getPlayerZone(player)

    if not zoneId then return end

    -- Determinar cuántos spawnear
    local currentCount = Spawner.getEnemyCountInZone(zoneId)
    local targetCount = CONFIG.DENSITY[zoneId] or 10

    if currentCount >= targetCount then
        return  -- Ya hay suficientes
    end

    local toSpawn = math.min(targetCount - currentCount, 3)  -- Máximo 3 por vez

    for i = 1, toSpawn do
        Spawner.spawnEnemy(zoneId, playerPos)
    end
end

-- Spawnear un enemigo específico
function Spawner.spawnEnemy(zoneId, playerPos)
    -- Elegir tipo aleatorio según zona
    local types = CONFIG.TYPES[zoneId] or {"Common"}
    local enemyType = Utility.randomChoice(types)

    -- Elegir spawn point
    local spawnPoints = CONFIG.SPAWN_POINTS[zoneId] or {}
    local spawnPoint

    if #spawnPoints > 0 then
        spawnPoint = Utility.randomChoice(spawnPoints)
    else
        -- Spawn aleatorio cerca del jugador
        local angle = math.random() * math.pi * 2
        local distance = Utility.randomRange(CONFIG.SPAWN_DISTANCE.min, CONFIG.SPAWN_DISTANCE.max)
        spawnPoint = playerPos + Vector3.new(
            math.cos(angle) * distance,
            0,
            math.sin(angle) * distance
        )
    end

    -- Crear enemigo
    local position = typeof(spawnPoint) == "CFrame" and spawnPoint.Position or spawnPoint
    local enemy = EnemyAI.createEnemy(enemyType, position)

    -- Spawnear modelo en workspace
    local model = Spawner.createEnemyModel(enemy)
    if model then
        model.Parent = workspace.Zones[zoneId] or workspace
        enemy.model = model
        enemy.zone = zoneId

        table.insert(Spawner.activeEnemies, enemy)

        Utility.log("EnemySpawner", enemyType .. " spawned en " .. zoneId)
    end

    return enemy
end

-- Crear modelo visual del enemigo
function Spawner.createEnemyModel(enemy)
    -- Buscar template en ReplicatedStorage
    local templates = ReplicatedStorage:FindFirstChild("EnemyTemplates")
    if not templates then
        -- Crear modelo placeholder
        local model = Instance.new("Model")
        model.Name = enemy.type .. "_Enemy"

        local part = Instance.new("Part")
        part.Name = "HumanoidRootPart"
        part.Position = enemy.position
        part.Size = Vector3.new(2, 6, 2)

        -- Color según tipo
        local colors = {
            Common = Color3.fromRGB(100, 120, 80),
            Corredor = Color3.fromRGB(150, 80, 80),
            Blindado = Color3.fromRGB(60, 60, 60),
            Acechador = Color3.fromRGB(40, 40, 40),
        }
        part.Color = colors[enemy.type] or Color3.gray

        part.Parent = model
        model:SetPrimaryPartCFrame(CFrame.new(enemy.position))

        -- Humanoid para IA
        local humanoid = Instance.new("Humanoid")
        humanoid.MaxHealth = enemy.health
        humanoid.Health = enemy.health
        humanoid.Parent = model

        return model
    end

    local template = templates:FindFirstChild(enemy.type)
    if template then
        return template:Clone()
    end

    return nil
end

-- Obtener zona actual del jugador
function Spawner.getPlayerZone(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local rootPart = character.HumanoidRootPart

    for i = 1, 6 do
        local zone = workspace.Zones:FindFirstChild("Zone" .. i)
        if zone and zone:FindFirstChild("ZoneTrigger") then
            local trigger = zone.ZoneTrigger
            local bounds = trigger:GetExtentsSize()
            local center = trigger.CFrame.Position

            if math.abs(rootPart.Position.X - center.X) < bounds.X / 2 and
               math.abs(rootPart.Position.Z - center.Z) < bounds.Z / 2 then
                return "Zone" .. i
            end
        end
    end

    return "Zone1"  -- Default
end

-- Contar enemigos en una zona
function Spawner.getEnemyCountInZone(zoneId)
    local count = 0
    for _, enemy in ipairs(Spawner.activeEnemies) do
        if enemy.zone == zoneId then
            count = count + 1
        end
    end
    return count
end

-- Limpiar enemigos muertos
function Spawner.cleanupDeadEnemies()
    for i = #Spawner.activeEnemies, 1, -1 do
        local enemy = Spawner.activeEnemies[i]

        -- Verificar si el modelo existe y está vivo
        local isDead = false

        if enemy.model then
            local humanoid = enemy.model:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                isDead = true

                -- Limpiar modelo
                enemy.model:Destroy()
            end
        else
            isDead = true
        end

        if isDead then
            -- Notificar muerte para quests/moralidad
            local QuestEvent = ReplicatedStorage:FindFirstChild("QuestEvent")
            if QuestEvent then
                QuestEvent:FireAllClients("enemyKilled", enemy.type, enemy.zone)
            end

            table.remove(Spawner.activeEnemies, i)
        end
    end
end

-- Forzar spawn de jefe
function Spawner.spawnBoss(bossId, zoneId, position)
    Utility.log("EnemySpawner", "Spawn de jefe: " .. bossId)

    -- BossSpawner se encarga de esto
    local BossSpawner = require(ServerScriptService.Servers.BossSpawner)
    return BossSpawner.spawn(bossId, position)
end

-- Obtener estadísticas
function Spawner.getStats()
    return {
        activeEnemies = #Spawner.activeEnemies,
        maxActive = CONFIG.MAX_ACTIVE,
        spawnInterval = CONFIG.SPAWN_INTERVAL,
        byZone = Spawner.getEnemiesByZone(),
    }
end

-- Contar enemigos por zona
function Spawner.getEnemiesByZone()
    local counts = {}
    for _, enemy in ipairs(Spawner.activeEnemies) do
        counts[enemy.zone] = (counts[enemy.zone] or 0) + 1
    end
    return counts
end

-- Detener spawner
function Spawner.stop()
    Spawner.isRunning = false
    Utility.log("EnemySpawner", "Detenido")
end

-- Iniciar al cargar
task.spawn(function()
    task.wait(2)  -- Esperar a que el workspace cargue
    Spawner.init()
end)

return Spawner
