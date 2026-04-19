--[[
    RemoteHandler
    Maneja todas las conexiones de RemoteEvents del servidor
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = require(ReplicatedStorage.Modules.Utility)

local RemoteHandler = {}

-- Referencias a eventos
local events = {}

-- Obtener o crear referencia a evento
local function getEvent(name)
    if not events[name] then
        events[name] = ReplicatedStorage:FindFirstChild(name)
    end
    return events[name]
end

-- Inicializar handlers
function RemoteHandler.init()
    Utility.log("RemoteHandler", "Inicializando handlers...")

    -- MovementEvent
    local movementEvent = getEvent("MovementEvent")
    if movementEvent then
        movementEvent.OnServerEvent:Connect(function(player, action, value)
            RemoteHandler.handleMovement(player, action, value)
        end)
    end

    -- WeaponEvent
    local weaponEvent = getEvent("WeaponEvent")
    if weaponEvent then
        weaponEvent.OnServerEvent:Connect(function(player, action, ...)
            RemoteHandler.handleWeapon(player, action, ...)
        end)
    end

    -- UIEvent
    local uiEvent = getEvent("UIEvent")
    if uiEvent then
        uiEvent.OnServerEvent:Connect(function(player, action, ...)
            RemoteHandler.handleUI(player, action, ...)
        end)
    end

    -- InventoryEvent
    local inventoryEvent = getEvent("InventoryEvent")
    if inventoryEvent then
        inventoryEvent.OnServerEvent:Connect(function(player, action, ...)
            RemoteHandler.handleInventory(player, action, ...)
        end)
    end

    Utility.log("RemoteHandler", "Handlers inicializados")
end

-- Manejar movimientos
function RemoteHandler.handleMovement(player, action, value)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if action == "setSprinting" then
        -- El server valida si puede sprintear
        local canSprint = true  -- Aquí iría lógica de stamina
        if canSprint then
            humanoid.WalkSpeed = 28  -- Sprint speed
        end
    elseif action == "setCrouching" then
        if value then
            humanoid.WalkSpeed = 12  -- Crouch speed
            -- Hacer personaje más pequeño
        else
            humanoid.WalkSpeed = 20  -- Normal speed
        end
    end
end

-- Manejar armas
function RemoteHandler.handleWeapon(player, action, ...)
    local args = {...}

    if action == "fire" then
        local weapon = args[1]
        local hitPos = args[2]
        -- Validar y procesar disparo
        RemoteHandler.processWeaponFire(player, weapon, hitPos)
    elseif action == "reload" then
        local weapon = args[1]
        -- Validar y procesar recarga
        RemoteHandler.processReload(player, weapon)
    end
end

-- Procesar disparo
function RemoteHandler.processWeaponFire(player, weapon, hitPos)
    -- Aquí va la lógica de hitscan/proyectil
    local weaponEvent = getEvent("WeaponEvent")
    if weaponEvent then
        -- Replicar efecto a todos los clientes
        weaponEvent:FireAllClients("fireEffect", player, weapon, hitPos)
    end
end

-- Procesar recarga
function RemoteHandler.processReload(player, weapon)
    local weaponEvent = getEvent("WeaponEvent")
    if weaponEvent then
        weaponEvent:FireClient(player, "reloadComplete", weapon)
    end
end

-- Manejar UI
function RemoteHandler.handleUI(player, action, ...)
    -- Acciones de UI que requieren validación del server
    if action == "toggleInventory" then
        -- Abrir/cerrar inventario
    end
end

-- Manejar inventario
function RemoteHandler.handleInventory(player, action, ...)
    -- Usar item, equipar, etc.
    if action == "useItem" then
        local itemId = ...
        -- Validar y usar item
    end
end

return RemoteHandler
