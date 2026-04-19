--[[
    ZoneMapBuilder
    Constructor completo del mapa - Las 6 Zonas de El Olvidado

    Este script crea toda la estructura física de las zonas:
    - Geometría básica (edificios, calles, obstáculos)
    - Puntos de spawn de enemigos
    - Coleccionables (grabaciones, fotos, archivos, diario)
    - Puntos de merchants
    - Jefes
    - Iluminación específica
    - Triggers de eventos

    EJECUCIÓN: Copiar y pegar en Roblox Studio Script Editor
--]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[ZoneMapBuilder] Iniciando construcción del mapa...")

-- ============================================
-- CONFIGURACIÓN GENERAL
-- ============================================
local ZONES_CONFIG = {
    {
        id = 1,
        name = "El Barrio - Apartamento de Eddie",
        description = "El comienzo del fin. El apartamento de Eddie donde todo inicia.",
        difficulty = "Tutorial",
        expectedTime = "30-60 minutos",
        lighting = {
            Brightness = 1.2,
            ClockTime = 7,
            FogStart = 20,
            FogEnd = 80,
            Ambient = Color3.fromRGB(60, 55, 50),
            OutdoorAmbient = Color3.fromRGB(80, 75, 70),
        },
        enemies = {"Common"},
        enemyCount = 0, -- Zona tutorial, sin enemigos al inicio
        collectibles = {recordings = 3, photos = 2, files = 1, diary = 0},
        boss = nil,
        merchant = nil,
    },
    {
        id = 2,
        name = "Centro Comercial - Las Tiendas Muertas",
        description = "Laberinto de tiendas saqueadas. Primer encuentro con Lince.",
        difficulty = "Fácil",
        expectedTime = "2-3 horas",
        lighting = {
            Brightness = 0.5,
            ClockTime = 18,
            FogStart = 15,
            FogEnd = 40,
            Ambient = Color3.fromRGB(40, 35, 30),
            OutdoorAmbient = Color3.fromRGB(50, 45, 40),
        },
        enemies = {"Common", "Corredor"},
        enemyCount = 15,
        collectibles = {recordings = 6, photos = 4, files = 2, diary = 1},
        boss = "El Vigilante",
        merchant = "Lince",
    },
    {
        id = 3,
        name = "Estación de Policía - La Última Defensa",
        description = "Recursos potenciales. Algo encerrado en el sótano.",
        difficulty = "Medio",
        expectedTime = "3-4 horas",
        lighting = {
            Brightness = 0.3,
            ClockTime = 22,
            FogStart = 10,
            FogEnd = 30,
            Ambient = Color3.fromRGB(30, 25, 35),
            OutdoorAmbient = Color3.fromRGB(40, 35, 45),
        },
        enemies = {"Common", "Corredor", "Blindado"},
        enemyCount = 20,
        collectibles = {recordings = 7, photos = 4, files = 3, diary = 2},
        boss = "El Encerrado",
        merchant = "Nocthyr",
    },
    {
        id = 4,
        name = "Hospital - La Casa del Dolor",
        description = "El lugar más peligroso. Mutaciones extrañas.",
        difficulty = "Difícil",
        expectedTime = "4-5 horas",
        lighting = {
            Brightness = 0.4,
            ClockTime = 3,
            FogStart = 8,
            FogEnd = 25,
            Ambient = Color3.fromRGB(35, 45, 35),
            OutdoorAmbient = Color3.fromRGB(25, 35, 25),
        },
        enemies = {"Common", "Corredor", "Blindado", "Acechador"},
        enemyCount = 25,
        collectibles = {recordings = 8, photos = 4, files = 3, diary = 2},
        boss = "La Doctora",
        merchant = "Científico Botánico",
    },
    {
        id = 5,
        name = "Las Afueras - El Bosque Maldito",
        description = "Más abierto, pero no más seguro. Criaturas que cazan por sonido.",
        difficulty = "Medio-Difícil",
        expectedTime = "3-4 horas",
        lighting = {
            Brightness = 0.6,
            ClockTime = 16,
            FogStart = 25,
            FogEnd = 80,
            Ambient = Color3.fromRGB(50, 70, 50),
            OutdoorAmbient = Color3.fromRGB(60, 80, 60),
        },
        enemies = {"Common", "Corredor", "Acechador"},
        enemyCount = 12,
        collectibles = {recordings = 6, photos = 4, files = 2, diary = 2},
        boss = "La Manada",
        merchant = "El Héroe del Chocomilk",
    },
    {
        id = 6,
        name = "El Camino a Punto Cero - La Recta Final",
        description = "Todo lo aprendido se pone a prueba. El complejo militar.",
        difficulty = "Muy Difícil",
        expectedTime = "5-7 horas",
        lighting = {
            Brightness = 0.2,
            ClockTime = 0,
            FogStart = 5,
            FogEnd = 20,
            Ambient = Color3.fromRGB(20, 15, 25),
            OutdoorAmbient = Color3.fromRGB(30, 25, 35),
        },
        enemies = {"Common", "Corredor", "Blindado", "Acechador"},
        enemyCount = 18,
        collectibles = {recordings = 4, photos = 2, files = 1, diary = 1},
        boss = "Comandante Reyes",
        merchant = nil,
    },
}

-- ============================================
-- FUNCIONES DE CONSTRUCCIÓN
-- ============================================

-- Crear carpeta de zonas si no existe
local function createZonesFolder()
    local zones = Workspace:FindFirstChild("Zones")
    if not zones then
        zones = Instance.new("Folder")
        zones.Name = "Zones"
        zones.Parent = Workspace
        print("[ZoneMapBuilder] Carpeta Zones creada")
    end
    return zones
end

-- Crear zona individual
local function createZone(config)
    local zonesFolder = createZonesFolder()

    local zoneFolder = zonesFolder:FindFirstChild("Zone" .. config.id)
    if not zoneFolder then
        zoneFolder = Instance.new("Folder")
        zoneFolder.Name = "Zone" .. config.id
        zoneFolder.Parent = zonesFolder
    end

    -- Metadata
    local metadata = zoneFolder:FindFirstChild("Metadata")
    if not metadata then
        metadata = Instance.new("StringValue")
        metadata.Name = "Metadata"
        metadata.Parent = zoneFolder
    end
    metadata.Value = game:GetService("HttpService"):JSONEncode(config)

    print("[ZoneMapBuilder] Zona " .. config.id .. " creada: " .. config.name)
    return zoneFolder
end

-- Crear subcarpetas de zona
local function createZoneSubfolders(zoneFolder)
    local subfolders = {
        "Geometry",
        "SpawnPoints",
        "Enemies",
        "Collectibles",
        "Triggers",
        "Lighting",
        "Merchants",
        "Bosses",
        "Props",
        "Navigation"
    }

    for _, name in ipairs(subfolders) do
        local subfolder = zoneFolder:FindFirstChild(name)
        if not subfolder then
            subfolder = Instance.new("Folder")
            subfolder.Name = name
            subfolder.Parent = zoneFolder
        end
    end
end

-- Crear spawn point
local function createSpawnPoint(zoneFolder, position, name)
    local spawnsFolder = zoneFolder:FindFirstChild("SpawnPoints")
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = name or "SpawnPoint"
    spawn.CFrame = CFrame.new(position)
    spawn.Parent = spawnsFolder
    return spawn
end

-- Crear parte básica (pared, suelo, etc.)
local function createPart(parent, position, size, material, color, transparency, name, canCollide)
    local part = Instance.new("Part")
    part.Name = name or "Part"
    part.CFrame = CFrame.new(position)
    part.Size = size
    part.Material = material or Enum.Material.SmoothPlastic
    part.Color = color or Color3.fromRGB(128, 128, 128)
    part.Transparency = transparency or 0
    part.CanCollide = canCollide ~= false
    part.Anchored = true
    part.Parent = parent
    return part
end

-- Crear trigger de zona
local function createZoneTrigger(zoneFolder, position, size)
    local triggersFolder = zoneFolder:FindFirstChild("Triggers")
    local trigger = Instance.new("Part")
    trigger.Name = "ZoneTrigger"
    trigger.CFrame = CFrame.new(position)
    trigger.Size = size
    trigger.Transparency = 1
    trigger.CanCollide = false
    trigger.Anchored = true
    trigger.Material = Enum.Material.Neon
    trigger.Color = Color3.fromRGB(255, 0, 0)
    trigger.Parent = triggersFolder
    return trigger
end

-- Crear coleccionable
local function createCollectible(zoneFolder, position, collectibleType, id)
    local collectiblesFolder = zoneFolder:FindFirstChild("Collectibles")
    local collector = Instance.new("Model")
    collector.Name = collectibleType .. "_" .. id

    local part = Instance.new("Part")
    part.Name = "Collector"
    part.Size = Vector3.new(1, 1, 1)
    part.CFrame = CFrame.new(position)
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Parent = collector

    -- Color según tipo
    local colors = {
        recordings = Color3.fromRGB(100, 149, 237), -- Cornflower blue
        photos = Color3.fromRGB(255, 193, 37), -- Amber
        files = Color3.fromRGB(220, 220, 220), -- White
        diary = Color3.fromRGB(139, 69, 19), -- SaddleBrown
    }
    part.Color = colors[collectibleType] or Color3.white

    local value = Instance.new("StringValue")
    value.Name = "Type"
    value.Value = collectibleType
    value.Parent = collector

    local idValue = Instance.new("IntValue")
    idValue.Name = "ID"
    idValue.Value = id
    idValue.Parent = collector

    collector.Parent = collectiblesFolder
    return collector
end

-- Crear punto de enemigo
local function createEnemySpawn(zoneFolder, position, enemyType)
    local enemiesFolder = zoneFolder:FindFirstChild("Enemies")
    local spawn = Instance.new("Part")
    spawn.Name = "EnemySpawn_" .. enemyType
    spawn.CFrame = CFrame.new(position)
    spawn.Size = Vector3.new(2, 0.1, 2)
    spawn.Transparency = 0.5
    spawn.Material = Enum.Material.Neon
    spawn.CanCollide = false
    spawn.Anchored = true

    local typeValue = Instance.new("StringValue")
    typeValue.Name = "EnemyType"
    typeValue.Value = enemyType
    typeValue.Parent = spawn

    spawn.Parent = enemiesFolder
    return spawn
end

-- Crear punto de merchant
local function createMerchantSpawn(zoneFolder, position, merchantName)
    local merchantsFolder = zoneFolder:FindFirstChild("Merchants")
    local spawn = Instance.new("Part")
    spawn.Name = "MerchantSpawn_" .. merchantName
    spawn.CFrame = CFrame.new(position)
    spawn.Size = Vector3.new(3, 0.1, 3)
    spawn.Transparency = 0.3
    spawn.Material = Enum.Material.Neon
    spawn.CanCollide = false
    spawn.Anchored = true

    local nameValue = Instance.new("StringValue")
    nameValue.Name = "MerchantName"
    nameValue.Value = merchantName
    nameValue.Parent = spawn

    spawn.Parent = merchantsFolder
    return spawn
end

-- Crear arena de jefe
local function createBossArena(zoneFolder, position, size, bossName)
    local bossesFolder = zoneFolder:FindFirstChild("Bosses")
    local arena = Instance.new("Part")
    arena.Name = "BossArena_" .. bossName
    arena.CFrame = CFrame.new(position)
    arena.Size = size
    arena.Transparency = 0.7
    arena.Material = Enum.Material.Neon
    arena.Color = Color3.fromRGB(255, 0, 0)
    arena.CanCollide = false
    arena.Anchored = true
    arena.Parent = bossesFolder

    local bossValue = Instance.new("StringValue")
    bossValue.Name = "BossName"
    bossValue.Value = bossName
    bossValue.Parent = arena

    return arena
end

-- ============================================
-- CONSTRUCCIÓN DE ZONAS INDIVIDUALES
-- ============================================

-- ZONA 1: Apartamento de Eddie (Tutorial)
local function buildZone1()
    print("[ZoneMapBuilder] Construyendo Zona 1: Apartamento de Eddie...")

    local config = ZONES_CONFIG[1]
    local zoneFolder = createZone(config)
    createZoneSubfolders(zoneFolder)

    -- Spawn point (dentro del apartamento)
    createSpawnPoint(zoneFolder, Vector3.new(0, 5, 0), "PlayerSpawn")

    -- Geometría básica del apartamento
    local geometryFolder = zoneFolder:FindFirstChild("Geometry")

    -- Suelo
    createPart(geometryFolder, Vector3.new(0, 0, 0), Vector3.new(40, 1, 40),
        Enum.Material.Concrete, Color3.fromRGB(100, 100, 100), 0, "Floor")

    -- Paredes
    createPart(geometryFolder, Vector3.new(-20, 5, 0), Vector3.new(1, 10, 40),
        Enum.Material.Brick, Color3.fromRGB(139, 90, 43), 0, "Wall_Left")
    createPart(geometryFolder, Vector3.new(20, 5, 0), Vector3.new(1, 10, 40),
        Enum.Material.Brick, Color3.fromRGB(139, 90, 43), 0, "Wall_Right")
    createPart(geometryFolder, Vector3.new(0, 5, -20), Vector3.new(40, 10, 1),
        Enum.Material.Brick, Color3.fromRGB(139, 90, 43), 0, "Wall_Back")
    createPart(geometryFolder, Vector3.new(0, 5, 20), Vector3.new(40, 10, 1),
        Enum.Material.Brick, Color3.fromRGB(139, 90, 43), 0, "Wall_Front")

    -- Techo
    createPart(geometryFolder, Vector3.new(0, 10, 0), Vector3.new(40, 1, 40),
        Enum.Material.Concrete, Color3.fromRGB(80, 80, 80), 0, "Ceiling")

    -- Habitaciones internas (paredes divisorias)
    createPart(geometryFolder, Vector3.new(-5, 5, 0), Vector3.new(1, 10, 20),
        Enum.Material.SmoothPlastic, Color3.fromRGB(200, 200, 200), 0, "Wall_Bedroom")
    createPart(geometryFolder, Vector3.new(10, 5, -5), Vector3.new(15, 10, 1),
        Enum.Material.SmoothPlastic, Color3.fromRGB(200, 200, 200), 0, "Wall_Kitchen")

    -- Puerta de salida (trigger)
    createZoneTrigger(zoneFolder, Vector3.new(0, 1, 18), Vector3.new(6, 4, 2))

    -- Coleccionables iniciales
    createCollectible(zoneFolder, Vector3.new(-8, 2, -8), "recordings", 1) -- Grabación en mesa de noche
    createCollectible(zoneFolder, Vector3.new(12, 2, 8), "recordings", 2) -- Grabación en cocina
    createCollectible(zoneFolder, Vector3.new(0, 2, -15), "recordings", 3) -- Grabación en sala
    createCollectible(zoneFolder, Vector3.new(-8, 2, 5), "photos", 1) -- Foto de familia
    createCollectible(zoneFolder, Vector3.new(15, 2, -12), "photos", 2) -- Foto padres
    createCollectible(zoneFolder, Vector3.new(5, 2, 10), "files", 1) -- Archivo PharmaCorp

    print("[ZoneMapBuilder] Zona 1 completada")
end

-- ZONA 2: Centro Comercial
local function buildZone2()
    print("[ZoneMapBuilder] Construyendo Zona 2: Centro Comercial...")

    local config = ZONES_CONFIG[2]
    local zoneFolder = createZone(config)
    createZoneSubfolders(zoneFolder)

    -- Spawn point (entrada del mall)
    createSpawnPoint(zoneFolder, Vector3.new(100, 5, 0), "PlayerSpawn")

    local geometryFolder = zoneFolder:FindFirstChild("Geometry")

    -- Suelo principal del mall
    createPart(geometryFolder, Vector3.new(100, 0, 0), Vector3.new(200, 1, 150),
        Enum.Material.Marble, Color3.fromRGB(60, 60, 65), 0, "MainFloor")

    -- Tiendas (módulos repetidos)
    local shopPositions = {
        Vector3.new(20, 5, -60), Vector3.new(60, 5, -60), Vector3.new(100, 5, -60),
        Vector3.new(140, 5, -60), Vector3.new(180, 5, -60),
        Vector3.new(20, 5, 60), Vector3.new(60, 5, 60), Vector3.new(100, 5, 60),
        Vector3.new(140, 5, 60), Vector3.new(180, 5, 60),
    }

    for i, pos in ipairs(shopPositions) do
        -- Paredes de tienda
        createPart(geometryFolder, pos, Vector3.new(35, 12, 1),
            Enum.Material.Glass, Color3.fromRGB(100, 150, 200), 0.3, "ShopFront_" .. i)
        createPart(geometryFolder, pos + Vector3.new(0, 5, -25), Vector3.new(35, 12, 1),
            Enum.Material.Brick, Color3.fromRGB(120, 100, 80), 0, "ShopBack_" .. i)
    end

    -- Escaleras mecánicas (decorativas)
    createPart(geometryFolder, Vector3.new(100, 5, 0), Vector3.new(20, 1, 60),
        Enum.Material.Metal, Color3.fromRGB(80, 80, 80), 0, "Escalator_Base")

    -- Fuente central (punto de encuentro)
    createPart(geometryFolder, Vector3.new(100, 1, 0), Vector3.new(30, 1, 30),
        Enum.Material.Marble, Color3.fromRGB(180, 180, 200), 0, "Fountain_Base")
    createPart(geometryFolder, Vector3.new(100, 3, 0), Vector3.new(5, 4, 5),
        Enum.Material.Marble, Color3.fromRGB(180, 180, 200), 0, "Fountain_Column")

    -- Trigger de salida
    createZoneTrigger(zoneFolder, Vector3.new(100, 1, 70), Vector3.new(40, 4, 5))

    -- Spawns de enemigos
    for i = 1, 8 do
        local x = 20 + (i * 20)
        local z = -40 + ((i % 2) * 80)
        createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Common")
    end
    for i = 1, 3 do
        createEnemySpawn(zoneFolder, Vector3.new(50 + (i * 40), 1, 0), "Corredor")
    end

    -- Merchant: Lince (escondido en tienda trasera)
    createMerchantSpawn(zoneFolder, Vector3.new(180, 1, -50), "Lince")

    -- Boss Arena: El Vigilante (seguridad del mall)
    createBossArena(zoneFolder, Vector3.new(100, 1, -70), Vector3.new(50, 1, 30), "El_Vigilante")

    -- Coleccionables
    for i = 1, 6 do
        local x = 30 + (i * 25)
        local z = (i % 2 == 0) and -30 or 30
        createCollectible(zoneFolder, Vector3.new(x, 2, z), "recordings", i)
    end
    for i = 1, 4 do
        createCollectible(zoneFolder, Vector3.new(100, 2, (i * 20) - 40), "photos", i)
    end
    createCollectible(zoneFolder, Vector3.new(180, 2, 50), "files", 1)
    createCollectible(zoneFolder, Vector3.new(20, 2, 50), "files", 2)
    createCollectible(zoneFolder, Vector3.new(100, 8, 0), "diary", 1) -- En techo

    print("[ZoneMapBuilder] Zona 2 completada")
end

-- ZONA 3: Estación de Policía
local function buildZone3()
    print("[ZoneMapBuilder] Construyendo Zona 3: Estación de Policía...")

    local config = ZONES_CONFIG[3]
    local zoneFolder = createZone(config)
    createZoneSubfolders(zoneFolder)

    -- Spawn point (entrada principal)
    createSpawnPoint(zoneFolder, Vector3.new(200, 5, 0), "PlayerSpawn")

    local geometryFolder = zoneFolder:FindFirstChild("Geometry")

    -- Edificio principal de policía
    createPart(geometryFolder, Vector3.new(200, 0, 0), Vector3.new(120, 1, 80),
        Enum.Material.Concrete, Color3.fromRGB(90, 90, 100), 0, "GroundFloor")

    -- Paredes exteriores
    createPart(geometryFolder, Vector3.new(140, 15, 0), Vector3.new(1, 30, 80),
        Enum.Material.Concrete, Color3.fromRGB(100, 100, 110), 0, "Wall_Left")
    createPart(geometryFolder, Vector3.new(260, 15, 0), Vector3.new(1, 30, 80),
        Enum.Material.Concrete, Color3.fromRGB(100, 100, 110), 0, "Wall_Right")
    createPart(geometryFolder, Vector3.new(200, 15, -40), Vector3.new(120, 30, 1),
        Enum.Material.Concrete, Color3.fromRGB(100, 100, 110), 0, "Wall_Back")
    createPart(geometryFolder, Vector3.new(200, 15, 40), Vector3.new(120, 30, 1),
        Enum.Material.Concrete, Color3.fromRGB(100, 100, 110), 0, "Wall_Front")

    -- Segundo piso
    createPart(geometryFolder, Vector3.new(200, 15, 0), Vector3.new(118, 1, 78),
        Enum.Material.Concrete, Color3.fromRGB(95, 95, 105), 0, "SecondFloor")

    -- Celdas (divisiones internas)
    for i = 1, 6 do
        local x = 155 + (i * 15)
        createPart(geometryFolder, Vector3.new(x, 7, -20), Vector3.new(10, 14, 1),
            Enum.Material.Metal, Color3.fromRGB(60, 60, 60), 0, "Cell_Wall_" .. i)
    end

    -- Sótano (acceso al jefe)
    createPart(geometryFolder, Vector3.new(200, -10, 30), Vector3.new(40, 1, 30),
        Enum.Material.Concrete, Color3.fromRGB(50, 50, 50), 0, "Basement_Floor")
    createPart(geometryFolder, Vector3.new(200, 0, 30), Vector3.new(1, 10, 30),
        Enum.Material.Metal, Color3.fromRGB(40, 40, 40), 0.5, "Basement_Gate")

    -- Trigger de salida
    createZoneTrigger(zoneFolder, Vector3.new(200, 1, -35), Vector3.new(30, 4, 5))

    -- Spawns de enemigos
    for i = 1, 10 do
        local x = 150 + (i * 10)
        local z = -30 + ((i % 2) * 60)
        createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Common")
    end
    for i = 1, 5 do
        createEnemySpawn(zoneFolder, Vector3.new(180 + (i * 15), 1, 0), "Corredor")
    end
    for i = 1, 3 do
        createEnemySpawn(zoneFolder, Vector3.new(220, 16, -20 + (i * 20)), "Blindado")
    end

    -- Merchant: Nocthyr (en oficina del capitán)
    createMerchantSpawn(zoneFolder, Vector3.new(250, 16, 30), "Nocthyr")

    -- Boss Arena: El Encerrado (sótano)
    createBossArena(zoneFolder, Vector3.new(200, -9, 30), Vector3.new(35, 1, 25), "El_Encerrado")

    -- Coleccionables
    for i = 1, 7 do
        local x = 150 + (i * 15)
        local z = (i % 2 == 0) and 25 or -25
        createCollectible(zoneFolder, Vector3.new(x, 2, z), "recordings", i)
    end
    for i = 1, 4 do
        createCollectible(zoneFolder, Vector3.new(200, 17, -30 + (i * 15)), "photos", i)
    end
    for i = 1, 3 do
        createCollectible(zoneFolder, Vector3.new(170 + (i * 20), 2, 35), "files", i)
    end
    createCollectible(zoneFolder, Vector3.new(200, -8, 25), "diary", 1)
    createCollectible(zoneFolder, Vector3.new(200, -8, 35), "diary", 2)

    print("[ZoneMapBuilder] Zona 3 completada")
end

-- ZONA 4: Hospital
local function buildZone4()
    print("[ZoneMapBuilder] Construyendo Zona 4: Hospital...")

    local config = ZONES_CONFIG[4]
    local zoneFolder = createZone(config)
    createZoneSubfolders(zoneFolder)

    -- Spawn point (entrada de emergencias)
    createSpawnPoint(zoneFolder, Vector3.new(300, 5, 0), "PlayerSpawn")

    local geometryFolder = zoneFolder:FindFirstChild("Geometry")

    -- Suelo del hospital
    createPart(geometryFolder, Vector3.new(300, 0, 0), Vector3.new(150, 1, 120),
        Enum.Material.Marble, Color3.fromRGB(200, 210, 200), 0, "HospitalFloor")

    -- Paredes exteriores (hospital más grande)
    createPart(geometryFolder, Vector3.new(225, 20, 0), Vector3.new(1, 40, 120),
        Enum.Material.Concrete, Color3.fromRGB(220, 230, 220), 0, "Wall_Left")
    createPart(geometryFolder, Vector3.new(375, 20, 0), Vector3.new(1, 40, 120),
        Enum.Material.Concrete, Color3.fromRGB(220, 230, 220), 0, "Wall_Right")
    createPart(geometryFolder, Vector3.new(300, 20, -60), Vector3.new(150, 40, 1),
        Enum.Material.Concrete, Color3.fromRGB(220, 230, 220), 0, "Wall_Back")
    createPart(geometryFolder, Vector3.new(300, 20, 60), Vector3.new(150, 40, 1),
        Enum.Material.Concrete, Color3.fromRGB(220, 230, 220), 0, "Wall_Front")

    -- Habitaciones del hospital (módulos)
    local roomPositions = {
        {x = 250, z = -40}, {x = 280, z = -40}, {x = 310, z = -40},
        {x = 340, z = -40}, {x = 250, z = 40}, {x = 280, z = 40},
        {x = 310, z = 40}, {x = 340, z = 40},
    }

    for i, pos in ipairs(roomPositions) do
        -- Paredes de habitación
        createPart(geometryFolder, Vector3.new(pos.x, 10, pos.z), Vector3.new(25, 20, 1),
            Enum.Material.SmoothPlastic, Color3.fromRGB(230, 240, 230), 0, "Room_Wall_" .. i)
    end

    -- Ala pediátrica (zona especial - más oscura)
    createPart(geometryFolder, Vector3.new(300, 0, 80), Vector3.new(80, 1, 30),
        Enum.Material.Marble, Color3.fromRGB(180, 200, 180), 0, "Pediatric_Wing")

    -- Quirófanos (centro del hospital)
    createPart(geometryFolder, Vector3.new(300, 1, 0), Vector3.new(60, 1, 40),
        Enum.Material.Metal, Color3.fromRGB(150, 160, 150), 0, "Surgery_Room_Floor")

    -- Trigger de salida
    createZoneTrigger(zoneFolder, Vector3.new(300, 1, -55), Vector3.new(40, 4, 5))

    -- Spawns de enemigos
    for i = 1, 12 do
        local x = 240 + (i * 10)
        local z = -30 + ((i % 2) * 60)
        createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Common")
    end
    for i = 1, 6 do
        createEnemySpawn(zoneFolder, Vector3.new(260 + (i * 15), 1, 10), "Corredor")
    end
    for i = 1, 4 do
        createEnemySpawn(zoneFolder, Vector3.new(300, 1, -40 + (i * 20)), "Blindado")
    end
    for i = 1, 3 do
        createEnemySpawn(zoneFolder, Vector3.new(350, 1, -30 + (i * 25)), "Acechador")
    end

    -- Merchant: Científico Botánico (invernadero del hospital)
    createMerchantSpawn(zoneFolder, Vector3.new(360, 1, 50), "Cientifico_Botanico")

    -- Boss Arena: La Doctora (quirófano principal)
    createBossArena(zoneFolder, Vector3.new(300, 1, 0), Vector3.new(50, 1, 35), "La_Doctora")

    -- Coleccionables
    for i = 1, 8 do
        local x = 240 + (i * 15)
        local z = (i % 2 == 0) and 45 or -45
        createCollectible(zoneFolder, Vector3.new(x, 2, z), "recordings", i)
    end
    for i = 1, 4 do
        createCollectible(zoneFolder, Vector3.new(300, 22, -50 + (i * 20)), "photos", i)
    end
    for i = 1, 3 do
        createCollectible(zoneFolder, Vector3.new(235, 2, -55 + (i * 25)), "files", i)
    end
    createCollectible(zoneFolder, Vector3.new(300, 2, 75), "diary", 1) -- Ala pediátrica
    createCollectible(zoneFolder, Vector3.new(320, 2, 85), "diary", 2) -- Ala pediátrica

    print("[ZoneMapBuilder] Zona 4 completada")
end

-- ZONA 5: Las Afueras / El Bosque
local function buildZone5()
    print("[ZoneMapBuilder] Construyendo Zona 5: El Bosque...")

    local config = ZONES_CONFIG[5]
    local zoneFolder = createZone(config)
    createZoneSubfolders(zoneFolder)

    -- Spawn point (salida del hospital)
    createSpawnPoint(zoneFolder, Vector3.new(400, 5, 0), "PlayerSpawn")

    local geometryFolder = zoneFolder:FindFirstChild("Geometry")

    -- Suelo natural (tierra)
    createPart(geometryFolder, Vector3.new(400, 0, 0), Vector3.new(300, 1, 250),
        Enum.Material.Ground, Color3.fromRGB(62, 50, 35), 0, "Ground")

    -- Árboles (cilindros)
    local treePositions = {}
    for i = 1, 50 do
        local x = 260 + (math.random() * 280)
        local z = -100 + (math.random() * 200)
        -- Evitar camino central
        if math.abs(z) > 30 then
            table.insert(treePositions, Vector3.new(x, 15, z))
            local trunk = Instance.new("Part")
            trunk.Name = "Tree_" .. i
            trunk.CFrame = CFrame.new(x, 15, z)
            trunk.Size = Vector3.new(4, 30, 4)
            trunk.Material = Enum.Material.Wood
            trunk.Color = Color3.fromRGB(82, 58, 31)
            trunk.CanCollide = true
            trunk.Anchored = true
            trunk.Parent = geometryFolder

            -- Copa del árbol
            local leaves = Instance.new("Part")
            leaves.Name = "Tree_Leaves_" .. i
            leaves.CFrame = CFrame.new(x, 35, z)
            leaves.Size = Vector3.new(20, 15, 20)
            leaves.Material = Enum.Material.LeafyGrass
            leaves.Color = Color3.fromRGB(34, 68, 34)
            leaves.CanCollide = false
            leaves.Anchored = true
            leaves.Transparency = 0.3
            leaves.Parent = geometryFolder
        end
    end

    -- Camino principal
    createPart(geometryFolder, Vector3.new(400, 0.1, 0), Vector3.new(60, 0.2, 200),
        Enum.Material.Grass, Color3.fromRGB(50, 70, 40), 0, "MainPath")

    -- Cabaña abandonada (punto de interés)
    createPart(geometryFolder, Vector3.new(500, 5, 80), Vector3.new(30, 10, 25),
        Enum.Material.Wood, Color3.fromRGB(101, 67, 33), 0, "Cabin")

    -- Trigger de salida
    createZoneTrigger(zoneFolder, Vector3.new(550, 1, 0), Vector3.new(30, 4, 50))

    -- Spawns de enemigos (más dispersos)
    for i = 1, 6 do
        local x = 300 + (math.random() * 200)
        local z = -80 + (math.random() * 160)
        if math.abs(z) > 40 then
            createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Common")
        end
    end
    for i = 1, 4 do
        local x = 320 + (math.random() * 180)
        local z = -60 + (math.random() * 120)
        if math.abs(z) > 40 then
            createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Corredor")
        end
    end
    for i = 1, 2 do
        local x = 350 + (math.random() * 150)
        local z = (i == 1) and -70 or 70
        createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Acechador")
    end

    -- Merchant: El Héroe del Chocomilk (en el bosque)
    createMerchantSpawn(zoneFolder, Vector3.new(480, 1, -60), "Heroe_del_Chocomilk")

    -- Boss Arena: La Manada (claro del bosque)
    createBossArena(zoneFolder, Vector3.new(520, 1, 0), Vector3.new(60, 1, 50), "La_Manada")

    -- Coleccionables
    for i = 1, 6 do
        local x = 320 + (math.random() * 200)
        local z = -80 + (math.random() * 160)
        createCollectible(zoneFolder, Vector3.new(x, 3, z), "recordings", i)
    end
    for i = 1, 4 do
        local x = 350 + (math.random() * 150)
        local z = -50 + (math.random() * 100)
        createCollectible(zoneFolder, Vector3.new(x, 2, z), "photos", i)
    end
    createCollectible(zoneFolder, Vector3.new(500, 6, 80), "files", 1) -- En cabaña
    createCollectible(zoneFolder, Vector3.new(450, 2, 90), "files", 2) -- En claro
    createCollectible(zoneFolder, Vector3.new(380, 2, -70), "diary", 1)
    createCollectible(zoneFolder, Vector3.new(550, 2, 60), "diary", 2)

    print("[ZoneMapBuilder] Zona 5 completada")
end

-- ZONA 6: El Camino a Punto Cero
local function buildZone6()
    print("[ZoneMapBuilder] Construyendo Zona 6: Punto Cero...")

    local config = ZONES_CONFIG[6]
    local zoneFolder = createZone(config)
    createZoneSubfolders(zoneFolder)

    -- Spawn point (entrada del complejo)
    createSpawnPoint(zoneFolder, Vector3.new(600, 5, 0), "PlayerSpawn")

    local geometryFolder = zoneFolder:FindFirstChild("Geometry")

    -- Suelo del complejo militar
    createPart(geometryFolder, Vector3.new(600, 0, 0), Vector3.new(200, 1, 150),
        Enum.Material.Metal, Color3.fromRGB(60, 65, 60), 0, "ComplexFloor")

    -- Paredes del complejo (altas y reforzadas)
    createPart(geometryFolder, Vector3.new(500, 30, 0), Vector3.new(1, 60, 150),
        Enum.Material.Concrete, Color3.fromRGB(80, 85, 80), 0, "Wall_Left")
    createPart(geometryFolder, Vector3.new(700, 30, 0), Vector3.new(1, 60, 150),
        Enum.Material.Concrete, Color3.fromRGB(80, 85, 80), 0, "Wall_Right")
    createPart(geometryFolder, Vector3.new(600, 30, -75), Vector3.new(200, 60, 1),
        Enum.Material.Concrete, Color3.fromRGB(80, 85, 80), 0, "Wall_Back")
    createPart(geometryFolder, Vector3.new(600, 30, 75), Vector3.new(200, 60, 1),
        Enum.Material.Concrete, Color3.fromRGB(80, 85, 80), 0, "Wall_Front")

    -- Edificios internos (módulos militares)
    local buildingPositions = {
        {x = 550, z = -50, size = Vector3.new(40, 25, 30)},
        {x = 650, z = -50, size = Vector3.new(40, 25, 30)},
        {x = 550, z = 50, size = Vector3.new(40, 25, 30)},
        {x = 650, z = 50, size = Vector3.new(40, 25, 30)},
    }

    for i, pos in ipairs(buildingPositions) do
        createPart(geometryFolder, Vector3.new(pos.x, 12.5, pos.z), pos.size,
            Enum.Material.Concrete, Color3.fromRGB(70, 75, 70), 0, "Building_" .. i)
    end

    -- Torre de vigilancia central
    createPart(geometryFolder, Vector3.new(600, 25, 0), Vector3.new(20, 50, 20),
        Enum.Material.Metal, Color3.fromRGB(50, 55, 50), 0, "WatchTower")

    -- Búnker subterráneo (acceso a Reyes)
    createPart(geometryFolder, Vector3.new(600, -10, 0), Vector3.new(50, 1, 40),
        Enum.Material.Concrete, Color3.fromRGB(40, 45, 40), 0, "Bunker_Floor")
    createPart(geometryFolder, Vector3.new(600, 0, 0), Vector3.new(1, 10, 40),
        Enum.Material.Metal, Color3.fromRGB(30, 35, 30), 0.7, "Bunker_Door")

    -- Trigger final (sin salida - es el final)
    createZoneTrigger(zoneFolder, Vector3.new(600, 1, 70), Vector3.new(30, 4, 10))

    -- Spawns de enemigos (élite)
    for i = 1, 8 do
        local x = 520 + (i * 20)
        local z = -60 + ((i % 2) * 120)
        createEnemySpawn(zoneFolder, Vector3.new(x, 1, z), "Common")
    end
    for i = 1, 5 do
        createEnemySpawn(zoneFolder, Vector3.new(540 + (i * 25), 1, 0), "Corredor")
    end
    for i = 1, 3 do
        createEnemySpawn(zoneFolder, Vector3.new(580, 26, -40 + (i * 40)), "Blindado")
    end
    for i = 1, 2 do
        createEnemySpawn(zoneFolder, Vector3.new(660, 1, -50 + (i * 100)), "Acechador")
    end

    -- Boss Arena: Comandante Reyes (búnker)
    createBossArena(zoneFolder, Vector3.new(600, -9, 0), Vector3.new(45, 1, 35), "Comandante_Reyes")

    -- Coleccionables finales
    for i = 1, 4 do
        local x = 530 + (i * 30)
        local z = (i % 2 == 0) and 60 or -60
        createCollectible(zoneFolder, Vector3.new(x, 2, z), "recordings", i)
    end
    createCollectible(zoneFolder, Vector3.new(600, 52, 0), "photos", 1) -- En torre
    createCollectible(zoneFolder, Vector3.new(550, 26, -40), "photos", 2) -- En edificio
    createCollectible(zoneFolder, Vector3.new(600, -8, 15), "files", 1) -- En búnker
    createCollectible(zoneFolder, Vector3.new(600, -8, -15), "diary", 1) -- En búnker

    print("[ZoneMapBuilder] Zona 6 completada")
end

-- ============================================
-- CONFIGURACIÓN DE ILUMINACIÓN GLOBAL
-- ============================================
local function setupGlobalLighting()
    print("[ZoneMapBuilder] Configurando iluminación global...")

    -- Configuración base de horror
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
        atmosphere.Parent = Lighting
    end
    atmosphere.Density = 0.3
    atmosphere.Color = Color3.fromRGB(30, 30, 30)
    atmosphere.Glare = 0.2
    atmosphere.Haze = 1.5

    print("[ZoneMapBuilder] Iluminación global configurada")
end

-- ============================================
-- EJECUCIÓN PRINCIPAL
-- ============================================
local function main()
    print("[ZoneMapBuilder] ========================================")
    print("[ZoneMapBuilder] CONSTRUCTOR DE MAPA - EL OLVIDADO")
    print("[ZoneMapBuilder] ========================================")

    -- Configurar iluminación
    setupGlobalLighting()

    -- Construir todas las zonas
    buildZone1() -- Apartamento de Eddie
    buildZone2() -- Centro Comercial
    buildZone3() -- Estación de Policía
    buildZone4() -- Hospital
    buildZone5() -- El Bosque
    buildZone6() -- Punto Cero

    print("[ZoneMapBuilder] ========================================")
    print("[ZoneMapBuilder] ¡MAPA COMPLETADO EXITOSAMENTE!")
    print("[ZoneMapBuilder] ========================================")
    print("[ZoneMapBuilder] Zonas creadas: 6")
    print("[ZoneMapBuilder] Total coleccionables: 74")
    print("[ZoneMapBuilder] Total enemigos: ~90")
    print("[ZoneMapBuilder] Jefes: 5")
    print("[ZoneMapBuilder] Merchants: 3")
    print("[ZoneMapBuilder] ========================================")
    print("[ZoneMapBuilder] PRÓXIMOS PASOS:")
    print("[ZoneMapBuilder] 1. Revisar cada zona en Roblox Studio")
    print("[ZoneMapBuilder] 2. Ajustar geometría y diseño")
    print("[ZoneMapBuilder] 3. Agregar detalles y decoración")
    print("[ZoneMapBuilder] 4. Configurar scripts de enemigos")
    print("[ZoneMapBuilder] 5. Implementar jefes y merchants")
    print("[ZoneMapBuilder] ========================================")
end

-- Ejecutar
task.spawn(main)

return {
    ZONES_CONFIG = ZONES_CONFIG,
    createZone = createZone,
    buildZone1 = buildZone1,
    buildZone2 = buildZone2,
    buildZone3 = buildZone3,
    buildZone4 = buildZone4,
    buildZone5 = buildZone5,
    buildZone6 = buildZone6,
    rebuildAll = main,
}
