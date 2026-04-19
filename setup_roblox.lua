--[[
    Setup Script - El Olvidado
    Ejecuta este script en Roblox Studio para crear toda la estructura
    Copia y pega esto en la consola de Roblox Studio (View → Script Editor)
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

print("[Setup] Creando estructura de El Olvidado...")

-- ============================================
-- REPLICATED STORAGE
-- ============================================
local function createReplicatedStorage()
    -- Carpeta Modules
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    if not modules then
        modules = Instance.new("Folder")
        modules.Name = "Modules"
        modules.Parent = ReplicatedStorage
    end

    -- Carpeta Remotes
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = ReplicatedStorage
    end

    -- Carpeta Assets
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then
        assets = Instance.new("Folder")
        assets.Name = "Assets"
        assets.Parent = ReplicatedStorage
    end

    -- Carpeta UI
    local ui = ReplicatedStorage:FindFirstChild("UI")
    if not ui then
        ui = Instance.new("Folder")
        ui.Name = "UI"
        ui.Parent = ReplicatedStorage
    end

    print("[Setup] ReplicatedStorage configurado")
end

-- ============================================
-- SERVER SCRIPT SERVICE
-- ============================================
local function createServerScriptService()
    -- Carpeta Servers
    local servers = ServerScriptService:FindFirstChild("Servers")
    if not servers then
        servers = Instance.new("Folder")
        servers.Name = "Servers"
        servers.Parent = ServerScriptService
    end

    -- Carpeta Modules
    local modules = ServerScriptService:FindFirstChild("Modules")
    if not modules then
        modules = Instance.new("Folder")
        modules.Name = "Modules"
        modules.Parent = ServerScriptService
    end

    print("[Setup] ServerScriptService configurado")
end

-- ============================================
-- STARTER PLAYER
-- ============================================
local function createStarterPlayer()
    -- Carpeta StarterPlayerScripts
    local playerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    if not playerScripts then
        playerScripts = Instance.new("StarterPlayerScripts")
        playerScripts.Name = "StarterPlayerScripts"
        playerScripts.Parent = StarterPlayer
    end

    -- Carpeta StarterCharacterScripts
    local characterScripts = StarterPlayer:FindFirstChild("StarterCharacterScripts")
    if not characterScripts then
        characterScripts = Instance.new("StarterCharacterScripts")
        characterScripts.Name = "StarterCharacterScripts"
        characterScripts.Parent = StarterPlayer
    end

    print("[Setup] StarterPlayer configurado")
end

-- ============================================
-- WORKSPACE
-- ============================================
local function createWorkspace()
    -- Carpeta Zones
    local zones = Workspace:FindFirstChild("Zones")
    if not zones then
        zones = Instance.new("Folder")
        zones.Name = "Zones"
        zones.Parent = Workspace
    end

    -- Default Spawn
    local defaultSpawn = Workspace:FindFirstChild("DefaultSpawn")
    if not defaultSpawn then
        defaultSpawn = Instance.new("SpawnLocation")
        defaultSpawn.Name = "DefaultSpawn"
        defaultSpawn.Parent = Workspace
        defaultSpawn.CFrame = CFrame.new(0, 5, 0)
    end

    print("[Setup] Workspace configurado")
end

-- ============================================
-- LIGHTING
-- ============================================
local function createLighting()
    Lighting.Brightness = 0.5
    Lighting.ClockTime = 18
    Lighting.FogStart = 10
    Lighting.FogEnd = 100
    Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 40)
    Lighting.Ambient = Color3.fromRGB(20, 20, 20)
    Lighting.Technology = Enum.Technology.Voxel

    -- Atmósfera
    local atmosphere = Lighting:FindFirstChild("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Density = 0.3
        atmosphere.Color = Color3.fromRGB(30, 30, 30)
        atmosphere.Parent = Lighting
    end

    print("[Setup] Lighting configurado")
end

-- ============================================
-- EJECUTAR
-- ============================================
createReplicatedStorage()
createServerScriptService()
createStarterPlayer()
createWorkspace()
createLighting()

print("[Setup] ¡Estructura creada exitosamente!")
print("[Setup] Ahora puedes copiar los archivos .lua a sus carpetas correspondientes")
