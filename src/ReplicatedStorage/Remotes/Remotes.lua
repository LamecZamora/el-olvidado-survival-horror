--[[
    Remotes
    Contenedor de todos los RemoteEvents y RemoteFunctions del juego
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

-- Función para crear o obtener RemoteEvent
function Remotes.createRemoteEvent(name)
    local event = ReplicatedStorage:FindFirstChild(name)
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = ReplicatedStorage
    end
    return event
end

-- Función para crear o obtener RemoteFunction
function Remotes.createRemoteFunction(name)
    local func = ReplicatedStorage:FindFirstChild(name)
    if not func then
        func = Instance.new("RemoteFunction")
        func.Name = name
        func.Parent = ReplicatedStorage
    end
    return func
end

-- Crear todos los remotes necesarios
function Remotes.init()
    -- Eventos de juego principal
    Remotes.createRemoteEvent("GameEvent")
    Remotes.createRemoteEvent("UIEvent")

    -- Eventos de movimiento
    Remotes.createRemoteEvent("MovementEvent")
    Remotes.createRemoteEvent("PositionEvent")

    -- Eventos de combate
    Remotes.createRemoteEvent("WeaponEvent")
    Remotes.createRemoteEvent("CombatEvent")

    -- Eventos de salud
    Remotes.createRemoteEvent("HealthEvent")
    Remotes.createRemoteEvent("DeathEvent")

    -- Eventos de stamina
    Remotes.createRemoteEvent("StaminaEvent")

    -- Eventos de crosshair
    Remotes.createRemoteEvent("CrosshairEvent")

    -- Eventos de zona
    Remotes.createRemoteEvent("ZoneEvent")

    -- Eventos de inventario
    Remotes.createRemoteEvent("InventoryEvent")

    -- Eventos de guardado
    Remotes.createRemoteEvent("SaveEvent")

    -- Eventos de progresión
    Remotes.createRemoteEvent("ProgressionEvent")

    -- Eventos de quests
    Remotes.createRemoteEvent("QuestEvent")

    -- Eventos de enemigos
    Remotes.createRemoteEvent("EnemyEvent")
    Remotes.createRemoteEvent("BossEvent")

    -- Eventos de audio
    Remotes.createRemoteEvent("AudioEvent")

    -- Eventos de moralidad
    Remotes.createRemoteEvent("MoralityEvent")

    -- Funciones remotas (request/response)
    Remotes.createRemoteFunction("RequestFunction")
    Remotes.createRemoteFunction("DataFunction")

    print("[Remotes] Todos los remotes creados exitosamente")
end

return Remotes
