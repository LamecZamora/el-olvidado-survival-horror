--[[
    ZoneStructure
    Define la estructura de las 6 zonas del juego
    Este script crea la base de cada zona en Workspace
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuración de zonas
local ZONES = {
    {
        id = 1,
        name = "El Barrio",
        description = "El apartamento de Eddie. Primer contacto con los muertos.",
        difficulty = "Tutorial",
        expectedTime = "30-60 minutos",
        enemies = {"Common"},
        boss = nil,
        merchant = nil,
        collectibles = {
            recordings = 3,
            photos = 2,
            files = 1,
            diary = 0,
        },
        lighting = {
            Brightness = 1,
            ClockTime = 14,
            FogEnd = 50,
            OutdoorAmbient = Color3.fromRGB(80, 80, 80),
        },
    },
    {
        id = 2,
        name = "Centro Comercial",
        description = "Laberinto de tiendas saqueadas. Primer encuentro con Lince.",
        difficulty = "Fácil",
        expectedTime = "2-3 horas",
        enemies = {"Common", "Corredor"},
        boss = "El Vigilante",
        merchant = "Lince",
        collectibles = {
            recordings = 6,
            photos = 4,
            files = 2,
            diary = 1,
        },
        lighting = {
            Brightness = 0.5,
            ClockTime = 18,
            FogEnd = 30,
            OutdoorAmbient = Color3.fromRGB(40, 40, 40),
        },
    },
    {
        id = 3,
        name = "Estación de Policía",
        description = "Recursos potenciales. Algo encerrado en el sótano.",
        difficulty = "Medio",
        expectedTime = "3-4 horas",
        enemies = {"Common", "Corredor", "Blindado"},
        boss = "El Encerrado",
        merchant = "Nocthyr",
        collectibles = {
            recordings = 7,
            photos = 4,
            files = 3,
            diary = 2,
        },
        lighting = {
            Brightness = 0.3,
            ClockTime = 22,
            FogEnd = 25,
            OutdoorAmbient = Color3.fromRGB(20, 20, 30),
        },
    },
    {
        id = 4,
        name = "Hospital",
        description = "El lugar más peligroso. Mutaciones extrañas.",
        difficulty = "Difícil",
        expectedTime = "4-5 horas",
        enemies = {"Common", "Corredor", "Blindado", "Acechador"},
        boss = "La Doctora",
        merchant = "Científico Botánico",
        collectibles = {
            recordings = 8,
            photos = 4,
            files = 3,
            diary = 2,
        },
        lighting = {
            Brightness = 0.4,
            ClockTime = 3,
            FogEnd = 20,
            OutdoorAmbient = Color3.fromRGB(30, 40, 30),
        },
    },
    {
        id = 5,
        name = "Las Afueras / El Bosque",
        description = "Más abierto, pero no más seguro. Criaturas que cazan por sonido.",
        difficulty = "Medio-Difícil",
        expectedTime = "3-4 horas",
        enemies = {"Common", "Corredor", "Acechador"},
        boss = "La Manada",
        merchant = "El Héroe del Chocomilk",
        collectibles = {
            recordings = 6,
            photos = 4,
            files = 2,
            diary = 2,
        },
        lighting = {
            Brightness = 0.6,
            ClockTime = 16,
            FogEnd = 60,
            OutdoorAmbient = Color3.fromRGB(60, 80, 60),
        },
    },
    {
        id = 6,
        name = "El Camino a Punto Cero",
        description = "La recta final. Todo lo aprendido se pone a prueba.",
        difficulty = "Muy Difícil",
        expectedTime = "5-7 horas",
        enemies = {"Common", "Corredor", "Blindado", "Acechador"},
        boss = "Comandante Reyes",
        merchant = nil,
        collectibles = {
            recordings = 4,
            photos = 2,
            files = 1,
            diary = 1,
        },
        lighting = {
            Brightness = 0.2,
            ClockTime = 0,
            FogEnd = 15,
            OutdoorAmbient = Color3.fromRGB(10, 10, 10),
        },
    },
}

-- Crear estructura de zonas
local function createZones()
    local zonesFolder = Workspace:FindFirstChild("Zones")
    if not zonesFolder then
        zonesFolder = Instance.new("Folder")
        zonesFolder.Name = "Zones"
        zonesFolder.Parent = Workspace
    end

    for _, zoneConfig in ipairs(ZONES) do
        local zoneFolder = zonesFolder:FindFirstChild("Zone" .. zoneConfig.id)
        if not zoneFolder then
            zoneFolder = Instance.new("Folder")
            zoneFolder.Name = "Zone" .. zoneConfig.id
            zoneFolder.Parent = zonesFolder
        end

        -- Agregar metadata
        local metadata = zoneFolder:FindFirstChild("Metadata")
        if not metadata then
            metadata = Instance.new("StringValue")
            metadata.Name = "Metadata"
            metadata.Parent = zoneFolder
        end
        metadata.Value = game:GetService("HttpService"):JSONEncode(zoneConfig)

        -- Crear subcarpetas
        local subfolders = {"SpawnPoints", "Enemies", "Collectibles", "Triggers", "Lighting"}
        for _, subfolderName in ipairs(subfolders) do
            if not zoneFolder:FindFirstChild(subfolderName) then
                local subfolder = Instance.new("Folder")
                subfolder.Name = subfolderName
                subfolder.Parent = zoneFolder
            end
        end

        -- Crear ZoneTrigger
        local trigger = zoneFolder:FindFirstChild("ZoneTrigger")
        if not trigger then
            trigger = Instance.new("Part")
            trigger.Name = "ZoneTrigger"
            trigger.Size = Vector3.new(100, 1, 100)
            trigger.Transparency = 1
            trigger.CanCollide = false
            trigger.Anchored = true
            trigger.Parent = zoneFolder
        end

        -- Crear SpawnPoint default
        local spawnPoint = zoneFolder:FindFirstChild("SpawnPoint")
        if not spawnPoint then
            spawnPoint = Instance.new("SpawnLocation")
            spawnPoint.Name = "SpawnPoint"
            spawnPoint.Parent = zoneFolder
        end

        print("[ZoneStructure] Zona " .. zoneConfig.id .. " creada: " .. zoneConfig.name)
    end

    print("[ZoneStructure] Todas las zonas creadas correctamente")
end

-- Configurar lighting global
local function setupGlobalLighting()
    local lighting = game:GetService("Lighting")

    -- Configuración base de horror
    lighting.Brightness = 0.5
    lighting.ClockTime = 18
    lighting.FogStart = 10
    lighting.FogEnd = 100
    lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 40)
    lighting.Ambient = Color3.fromRGB(20, 20, 20)

    -- Tecnología
    lighting.Technology = Enum.Technology.Voxel
    lighting.ShadowSoftness = 0.5
    lighting.EnvironmentDiffuseScale = 0.5
    lighting.EnvironmentSpecularScale = 0.5

    -- Atmósfera
    local atmosphere = lighting:FindFirstChild("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = lighting
    end
    atmosphere.Density = 0.3
    atmosphere.Color = Color3.fromRGB(30, 30, 30)

    print("[ZoneStructure] Lighting global configurado")
end

-- Ejecutar
task.spawn(function()
    task.wait(1)
    createZones()
    setupGlobalLighting()
end)
