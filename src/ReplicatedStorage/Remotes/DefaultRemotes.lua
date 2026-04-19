--[[
    DefaultRemotes
    Crea todos los RemoteEvents y RemoteFunctions necesarios
    Ejecutar una vez al inicio
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTES = {
    -- Eventos (Client → Server)
    "DamageEvent",
    "InventoryEvent",
    "DialogueEvent",
    "QuestEvent",
    "CollectibleEvent",
    "ZoneEvent",
    "MoralityEvent",
    "WeaponEvent",
    "MovementEvent",
    "PositionEvent",
    "CombatEvent",
    "UIEvent",
    "StaminaEvent",
    "VoiceEvent",

    -- Funciones (Client ↔ Server)
    "SaveFunction",
    "LoadFunction",
    "ShopFunction",
    "HealFunction",
}

local function createRemotes()
    local created = 0

    for _, name in ipairs(REMOTES) do
        if not ReplicatedStorage:FindFirstChild(name) then
            local remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = ReplicatedStorage
            created = created + 1
        end
    end

    -- RemoteFunctions específicas
    if not ReplicatedStorage:FindFirstChild("SaveFunction") then
        local func = Instance.new("RemoteFunction")
        func.Name = "SaveFunction"
        func.Parent = ReplicatedStorage
    end

    if not ReplicatedStorage:FindFirstChild("LoadFunction") then
        local func = Instance.new("RemoteFunction")
        func.Name = "LoadFunction"
        func.Parent = ReplicatedStorage
    end

    if not ReplicatedStorage:FindFirstChild("ShopFunction") then
        local func = Instance.new("RemoteFunction")
        func.Name = "ShopFunction"
        func.Parent = ReplicatedStorage
    end

    print("[DefaultRemotes] " .. created .. " remotes creados correctamente")
end

-- Ejecutar al cargar
createRemotes()
