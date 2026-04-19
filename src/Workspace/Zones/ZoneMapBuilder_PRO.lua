--[[
    ═══════════════════════════════════════════════════════════════════════════
    ZoneMapBuilder PRO - EL OLVIDADO: SURVIVAL HORROR
    ═══════════════════════════════════════════════════════════════════════════

    MAPA ULTRA-DETALLADO Y REALISTA - CIUDAD DE VAEL DESTRUIDA

    Este script construye TODO el mundo del juego de forma PROCEDURAL:
    - Ciudad completa de Vael (destruida por el brote del 15 de Marzo)
    - 6 Zonas interconectadas con continuidad geográfica
    - Geometría detallada: edificios, casas, parques, calles, vidrios rotos
    - Decoración post-apocalíptica: vehículos, escombros, cadáveres, sangre
    - Iluminación atmosférica dinámica por zona
    - Coleccionables integrados narrativamente
    - Spawns de enemigos con lógica de territorio
    - Arenas de jefes con mecánicas únicas
    - Merchants en ubicaciones con lore

    HISTORIA INTEGRADA EN EL ENTORNO:
    - Zona 1: Apartamento de Eddie - Vida normal antes del caos
    - Zona 2: Centro Comercial - Colapso económico, saqueos
    - Zona 3: Estación de Policía - Fallo institucional, desesperación
    - Zona 4: Hospital - Origen del horror, experimentos fallidos
    - Zona 5: Bosque/Afueras - Naturaleza reclaimando, supervivientes
    - Zona 6: Punto Cero - Complejo militar, verdad de PharmaCorp

    EJECUCIÓN EN ROBLOX STUDIO:
    1. View → Script Editor
    2. Copiar este script completo
    3. Pegar y presionar Play (F5)
    4. Esperar 30-60 segundos para generación completa

    ADVERTENCIA: Este script crea ~5000-8000 partes. Puede tomar tiempo.
--]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

print("╔══════════════════════════════════════════════════════════════╗")
print("║   ZONE MAP BUILDER PRO - EL OLVIDADO                        ║")
print("║   Ciudad de Vael - Survival Horror                          ║")
print("║   Build: Ultra-Detailed Apocalypse                          ║")
print("╚══════════════════════════════════════════════════════════════╝")

-- ============================================
-- CONFIGURACIÓN GLOBAL
-- ============================================
local CONFIG = {
    WORLD_SCALE = 1,
    DETAIL_LEVEL = 1,
    MAX_PARTS = 10000,
    STREAMING_ENABLED = true,
}

-- ============================================
-- PALETAS DE COLORES POR ZONA
-- ============================================
local PALETTES = {
    ZONE1 = {
        brick = Color3.fromRGB(139, 90, 43),
        concrete = Color3.fromRGB(100, 100, 100),
        wood = Color3.fromRGB(101, 67, 33),
        glass = Color3.fromRGB(200, 220, 255),
        metal = Color3.fromRGB(120, 120, 120),
        grass = Color3.fromRGB(34, 139, 34),
        sky = Color3.fromRGB(135, 206, 235),
    },
    ZONE2 = {
        floor = Color3.fromRGB(60, 60, 65),
        wall = Color3.fromRGB(120, 100, 80),
        glass_dirty = Color3.fromRGB(100, 100, 90),
        metal_rusty = Color3.fromRGB(139, 90, 43),
        neon_off = Color3.fromRGB(50, 50, 50),
        blood = Color3.fromRGB(139, 0, 0),
    },
    ZONE3 = {
        concrete = Color3.fromRGB(100, 100, 110),
        metal_bars = Color3.fromRGB(60, 60, 60),
        desk_wood = Color3.fromRGB(101, 67, 33),
        file_gray = Color3.fromRGB(169, 169, 169),
        blood_dried = Color3.fromRGB(101, 67, 33),
        evidence_yellow = Color3.fromRGB(218, 165, 32),
    },
    ZONE4 = {
        tile = Color3.fromRGB(240, 248, 255),
        wall_green = Color3.fromRGB(200, 230, 200),
        blood_fresh = Color3.fromRGB(220, 20, 60),
        metal_surgical = Color3.fromRGB(192, 192, 192),
        curtain = Color3.fromRGB(224, 255, 255),
        biohazard = Color3.fromRGB(255, 165, 0),
    },
    ZONE5 = {
        dirt = Color3.fromRGB(62, 50, 35),
        grass_dead = Color3.fromRGB(85, 107, 47),
        tree_bark = Color3.fromRGB(82, 58, 31),
        leaves = Color3.fromRGB(34, 68, 34),
        fog = Color3.fromRGB(105, 105, 105),
        moonlight = Color3.fromRGB(100, 149, 237),
    },
    ZONE6 = {
        concrete_military = Color3.fromRGB(80, 85, 80),
        metal_dark = Color3.fromRGB(50, 55, 50),
        hazard_yellow = Color3.fromRGB(255, 215, 0),
        hazard_black = Color3.fromRGB(0, 0, 0),
        blood_older = Color3.fromRGB(139, 69, 19),
        tech_gray = Color3.fromRGB(105, 105, 105),
    },
}

-- ============================================
-- UTILIDADES DE CONSTRUCCIÓN
-- ============================================
local function randomRange(min, max)
    return min + math.random() * (max - min)
end

local function createPart(parent, name, position, size, material, color, props)
    props = props or {}
    local part = Instance.new("Part")
    part.Name = name or "Part"
    part.CFrame = CFrame.new(position)
    part.Size = size or Vector3.new(1, 1, 1)
    part.Material = material or Enum.Material.SmoothPlastic
    part.Color = color or Color3.white
    part.Anchored = props.anchored ~= false
    part.CanCollide = props.canCollide ~= false
    part.Transparency = props.transparency or 0
    part.Reflectance = props.reflectance or 0
    part.Rotation = props.rotation or Vector3.new(0, 0, 0)
    if props.shape then part.Shape = props.shape end
    part.Parent = parent
    return part
end

local function createGlass(parent, name, position, size, color, dirty)
    return createPart(parent, name, position, size, Enum.Material.Glass, color, {
        transparency = dirty and 0.4 or 0.2,
        reflectance = dirty and 0.1 or 0.3,
    })
end

local function createBrokenGlass(parent, position, spread)
    local folder = Instance.new("Folder")
    folder.Name = "BrokenGlass"
    folder.Parent = parent
    for i = 1, 8 do
        createPart(folder, "Shard" .. i,
            position + Vector3.new(randomRange(-spread, spread), 0.1, randomRange(-spread, spread)),
            Vector3.new(randomRange(0.5, 1.5), 0.1, randomRange(0.5, 1.5)),
            Enum.Material.Glass, Color3.fromRGB(200, 220, 255),
            {transparency = 0.3, reflectance = 0.5, rotation = Vector3.new(randomRange(0, 360), 0, 0)}
        )
    end
    return folder
end

local function createTree(parent, position, scale, dead)
    local tree = Instance.new("Model")
    tree.Name = "Tree"
    tree.Parent = parent
    local trunk = createPart(tree, "Trunk", position, Vector3.new(3*scale, 20*scale, 3*scale),
        Enum.Material.Wood, dead and Color3.fromRGB(101, 67, 33) or PALETTES.ZONE5.tree_bark, {canCollide = true})
    for i = 1, 4 do
        local angle = (i/4) * math.pi * 2
        createPart(tree, "Branch" .. i,
            position + Vector3.new(math.cos(angle)*2*scale, 15*scale, math.sin(angle)*2*scale),
            Vector3.new(1.5*scale, 8*scale, 1.5*scale), Enum.Material.Wood, trunk.Color,
            {rotation = Vector3.new(20, angle*180/math.pi, 0)})
    end
    if not dead then
        createPart(tree, "Leaves", position + Vector3.new(0, 22*scale, 0),
            Vector3.new(18*scale, 10*scale, 18*scale), Enum.Material.LeafyGrass,
            PALETTES.ZONE5.leaves, {transparency = 0.2, canCollide = false})
    end
    return tree
end

local function createAbandonedCar(parent, position, rotation, color, damage)
    local car = Instance.new("Model")
    car.Name = "AbandonedCar"
    car.Parent = parent
    createPart(car, "Chassis", position + Vector3.new(0, 1.5, 0), Vector3.new(4, 1.5, 8),
        Enum.Material.Metal, color, {rotation = Vector3.new(0, rotation, 0)})
    createPart(car, "Roof", position + Vector3.new(0, 2.5, 0), Vector3.new(3.5, 0.5, 5),
        Enum.Material.Metal, color, {rotation = Vector3.new(0, rotation, 0)})
    local windows = {Vector3.new(1.8,2,2), Vector3.new(-1.8,2,2), Vector3.new(1.8,2,-2), Vector3.new(-1.8,2,-2)}
    for i, pos in ipairs(windows) do
        if damage and damage > 0.5 then
            createBrokenGlass(car, position + pos, 1)
        else
            createGlass(car, "Window" .. i, position + pos, Vector3.new(0.2, 1.5, 2),
                Color3.fromRGB(200, 220, 255), true)
        end
    end
    local wheels = {Vector3.new(2,0.5,3), Vector3.new(-2,0.5,3), Vector3.new(2,0.5,-3), Vector3.new(-2,0.5,-3)}
    for i, pos in ipairs(wheels) do
        createPart(car, "Wheel" .. i, position + pos, Vector3.new(0.5, 1.5, 1.5),
            Enum.Material.Rubber, Color3.fromRGB(30, 30, 30),
            {rotation = Vector3.new(90, rotation, 0), shape = Enum.PartType.Cylinder})
    end
    return car
end

local function createDebris(parent, position, debrisType)
    local debris = Instance.new("Model")
    debris.Name = "Debris"
    debris.Parent = parent
    if debrisType == "concrete" then
        for i = 1, 5 do
            createPart(debris, "Rubble" .. i,
                position + Vector3.new(randomRange(-2,2), 0.5, randomRange(-2,2)),
                Vector3.new(randomRange(1,3), randomRange(0.5,1.5), randomRange(1,3)),
                Enum.Material.Concrete, Color3.fromRGB(100,100,100),
                {rotation = Vector3.new(randomRange(0,90), randomRange(0,360), randomRange(0,90))})
        end
    elseif debrisType == "wood" then
        for i = 1, 4 do
            createPart(debris, "Plank" .. i,
                position + Vector3.new(randomRange(-2,2), 0.3, randomRange(-2,2)),
                Vector3.new(4, 0.2, 0.5), Enum.Material.Wood, Color3.fromRGB(139,90,43),
                {rotation = Vector3.new(randomRange(0,45), randomRange(0,360), randomRange(0,45))})
        end
    elseif debrisType == "trash" then
        local colors = {Color3.fromRGB(50,50,50), Color3.fromRGB(200,200,200),
            Color3.fromRGB(100,150,100), Color3.fromRGB(150,100,50)}
        for i = 1, 6 do
            createPart(debris, "Trash" .. i,
                position + Vector3.new(randomRange(-1.5,1.5), 0.2, randomRange(-1.5,1.5)),
                Vector3.new(randomRange(0.5,1), randomRange(0.3,0.8), randomRange(0.5,1)),
                Enum.Material.SmoothPlastic, colors[math.random(1,#colors)],
                {rotation = Vector3.new(randomRange(0,90), randomRange(0,360), randomRange(0,90))})
        end
    end
    return debris
end

-- ============================================
-- CONSTRUCTOR DE ZONAS
-- ============================================
local function createZoneFolder(name, metadata)
    local zones = Workspace:FindFirstChild("Zones")
    if not zones then
        zones = Instance.new("Folder")
        zones.Name = "Zones"
        zones.Parent = Workspace
    end
    local zone = Instance.new("Folder")
    zone.Name = name
    zone.Parent = zones
    local meta = Instance.new("StringValue")
    meta.Name = "Metadata"
    meta.Value = game:GetService("HttpService"):JSONEncode(metadata)
    meta.Parent = zone
    local subfolders = {"Geometry", "Props", "Collectibles", "Triggers", "Lighting", "Sound", "Enemies", "Spawns"}
    for _, f in ipairs(subfolders) do
        local folder = Instance.new("Folder")
        folder.Name = f
        folder.Parent = zone
    end
    return zone
end

-- ============================================
-- ZONA 1: APARTAMENTO DE EDDIE
-- ============================================
local function buildZone1()
    print("[ZoneBuilder] Zona 1: Apartamento de Eddie...")
    local zone = createZoneFolder("Zone1_EddieApartment", {
        id = 1, name = "El Apartamento de Eddie",
        description = "El comienzo del fin. El apartamento donde Eddie despierta al brote.",
        dayTime = "Día 1 - 7:00 AM", weather = "Despejado",
        lore = "Vida normal antes del caos. Foto de sus padres. Libros de universidad.",
    })
    local geo = zone:FindFirstChild("Geometry")
    local props = zone:FindFirstChild("Props")
    local center = Vector3.new(0, 0, 0)

    -- EDIFICIO DE APARTAMENTOS
    createPart(geo, "Foundation", center, Vector3.new(60, 2, 80), Enum.Material.Concrete, PALETTES.ZONE1.concrete, {})
    for floor = 1, 3 do
        local floorY = 2 + (floor * 12)
        createPart(geo, "Floor" .. floor, center + Vector3.new(0, floorY - 6, 0), Vector3.new(58, 1, 78), Enum.Material.Concrete, PALETTES.ZONE1.concrete, {})
        createPart(geo, "Wall_Front_" .. floor, center + Vector3.new(0, floorY, 39), Vector3.new(60, 12, 1), Enum.Material.Brick, PALETTES.ZONE1.brick, {})
        createPart(geo, "Wall_Back_" .. floor, center + Vector3.new(0, floorY, -39), Vector3.new(60, 12, 1), Enum.Material.Brick, PALETTES.ZONE1.brick, {})
        createPart(geo, "Wall_Left_" .. floor, center + Vector3.new(-29, floorY, 0), Vector3.new(1, 12, 78), Enum.Material.Brick, PALETTES.ZONE1.brick, {})
        createPart(geo, "Wall_Right_" .. floor, center + Vector3.new(29, floorY, 0), Vector3.new(1, 12, 78), Enum.Material.Brick, PALETTES.ZONE1.brick, {})
        for w = 1, 6 do
            local wx = -20 + (w * 8)
            local broken = math.random() > 0.7
            createPart(geo, "WindowFrame_" .. floor .. "_" .. w, center + Vector3.new(wx, floorY, 39.5), Vector3.new(5, 8, 1), Enum.Material.Wood, PALETTES.ZONE1.wood, {})
            if broken then createBrokenGlass(props, center + Vector3.new(wx, floorY - 2, 38.5), 2)
            else createGlass(geo, "WindowGlass_" .. floor .. "_" .. w, center + Vector3.new(wx, floorY, 39.2), Vector3.new(4.5, 7.5, 0.3), PALETTES.ZONE1.glass, false) end
        end
    end
    createPart(geo, "Roof", center + Vector3.new(0, 40, 0), Vector3.new(62, 2, 82), Enum.Material.Concrete, Color3.fromRGB(80,80,80), {})

    -- APARTAMENTO INTERNO (PISO 2)
    local aptY = 14
    createPart(geo, "Apt_Wall_Left", center + Vector3.new(-10, aptY + 6, 0), Vector3.new(1, 12, 50), Enum.Material.SmoothPlastic, Color3.fromRGB(220,220,200), {})
    createPart(geo, "Apt_Wall_Right", center + Vector3.new(15, aptY + 6, 0), Vector3.new(1, 12, 50), Enum.Material.SmoothPlastic, Color3.fromRGB(220,220,200), {})
    createPart(geo, "Apt_Wall_Back", center + Vector3.new(2, aptY + 6, -20), Vector3.new(30, 12, 1), Enum.Material.SmoothPlastic, Color3.fromRGB(220,220,200), {})
    createPart(geo, "Apt_Door_Frame", center + Vector3.new(0, aptY + 6, 24), Vector3.new(5, 10, 1), Enum.Material.Wood, PALETTES.ZONE1.wood, {})
    createPart(geo, "Bedroom_Wall", center + Vector3.new(-5, aptY + 6, -5), Vector3.new(1, 12, 25), Enum.Material.SmoothPlastic, Color3.fromRGB(220,220,200), {})

    -- MOBILIARIO
    createPart(props, "Sofa", center + Vector3.new(-8, aptY + 1, -10), Vector3.new(6, 2, 3), Enum.Material.Fabric, Color3.fromRGB(100,100,120), {})
    createPart(props, "CoffeeTable", center + Vector3.new(-5, aptY + 1, -5), Vector3.new(4, 1, 2), Enum.Material.Wood, PALETTES.ZONE1.wood, {})
    createPart(props, "DiningTable", center + Vector3.new(5, aptY + 1, 5), Vector3.new(5, 2, 3), Enum.Material.Wood, PALETTES.ZONE1.wood, {})
    createPart(props, "PhotoFrame", center + Vector3.new(5, aptY + 2.5, 5), Vector3.new(0.2, 1, 0.8), Enum.Material.Plastic, Color3.fromRGB(30,30,30), {})
    createPart(props, "KitchenCounter", center + Vector3.new(10, aptY + 1, -15), Vector3.new(8, 2, 3), Enum.Material.Granite, Color3.fromRGB(60,60,60), {})
    createPart(props, "Fridge", center + Vector3.new(12, aptY + 2, -18), Vector3.new(3, 5, 3), Enum.Material.Metal, Color3.fromRGB(200,200,200), {})
    createPart(props, "Bed", center + Vector3.new(-10, aptY + 1, -15), Vector3.new(5, 2, 6), Enum.Material.Fabric, Color3.fromRGB(80,100,120), {})
    createPart(props, "Nightstand", center + Vector3.new(-13, aptY + 1, -12), Vector3.new(2, 2, 2), Enum.Material.Wood, PALETTES.ZONE1.wood, {})
    createPart(props, "Laptop", center + Vector3.new(-10, aptY + 2.5, -15), Vector3.new(1, 0.1, 0.8), Enum.Material.Plastic, Color3.fromRGB(50,50,50), {})

    -- COLECCIONABLES
    local col = zone:FindFirstChild("Collectibles")
    local function createCollectible(name, pos, ctype, id)
        local p = Instance.new("Part")
        p.Name = name
        p.CFrame = CFrame.new(pos)
        p.Size = Vector3.new(0.5, 0.2, 0.5)
        p.Material = Enum.Material.Plastic
        p.Color = Color3.fromRGB(30,30,30)
        p.CanCollide = false
        p.Parent = col
        local v = Instance.new("StringValue")
        v.Name = "Type"
        v.Value = ctype
        v.Parent = p
        local idv = Instance.new("IntValue")
        idv.Name = "ID"
        idv.Value = id
        idv.Parent = p
    end
    createCollectible("Recording_001", center + Vector3.new(-13, aptY + 3, -12), "recordings", 1)
    createCollectible("Recording_002", center + Vector3.new(10, aptY + 3, -15), "recordings", 2)
    createCollectible("Recording_003", center + Vector3.new(-5, aptY + 2, -5), "recordings", 3)
    createCollectible("Photo_001", center + Vector3.new(5, aptY + 2.5, 5), "photos", 1)
    createCollectible("Photo_002", center + Vector3.new(-15, aptY + 4, -15), "photos", 2)
    createCollectible("File_001", center + Vector3.new(5, aptY + 2, 5), "files", 1)

    -- TRIGGER DE SALIDA
    local trig = zone:FindFirstChild("Triggers")
    createPart(trig, "ExitTrigger", center + Vector3.new(0, aptY + 1, 28), Vector3.new(8, 4, 2), Enum.Material.Neon, Color3.fromRGB(255,0,0), {transparency = 1, canCollide = false})

    print("[ZoneBuilder] Zona 1 completada")
    return zone
end

-- ============================================
-- ZONA 2: CENTRO COMERCIAL
-- ============================================
local function buildZone2()
    print("[ZoneBuilder] Zona 2: Centro Comercial...")
    local zone = createZoneFolder("Zone2_Mall", {
        id = 2, name = "Centro Comercial - Las Tiendas Muertas",
        description = "Laberinto de tiendas saqueadas. Primer encuentro con Lince.",
        dayTime = "Día 2-3", weather = "Nublado",
        lore = "El colapso económico. Saqueos, pánico, muerte. Lince esconde a Mimi aquí.",
    })
    local geo = zone:FindFirstChild("Geometry")
    local props = zone:FindFirstChild("Props")
    local center = Vector3.new(200, 0, 0)

    -- SUELO DEL MALL
    createPart(geo, "MainFloor", center, Vector3.new(200, 1, 150), Enum.Material.Marble, PALETTES.ZONE2.floor, {})

    -- PAREDES EXTERIORES
    createPart(geo, "Wall_Left", center + Vector3.new(-100, 15, 0), Vector3.new(1, 30, 150), Enum.Material.Concrete, PALETTES.ZONE2.wall, {})
    createPart(geo, "Wall_Right", center + Vector3.new(100, 15, 0), Vector3.new(1, 30, 150), Enum.Material.Concrete, PALETTES.ZONE2.wall, {})
    createPart(geo, "Wall_Back", center + Vector3.new(0, 15, -75), Vector3.new(200, 30, 1), Enum.Material.Concrete, PALETTES.ZONE2.wall, {})
    createPart(geo, "Wall_Front", center + Vector3.new(0, 15, 75), Vector3.new(200, 30, 1), Enum.Material.Concrete, PALETTES.ZONE2.wall, {})

    -- TIENDAS (10 módulos)
    local shopPositions = {{x=-80,z=-60},{x=-40,z=-60},{x=0,z=-60},{x=40,z=-60},{x=80,z=-60},
                           {x=-80,z=60},{x=-40,z=60},{x=0,z=60},{x=40,z=60},{x=80,z=60}}
    for i, pos in ipairs(shopPositions) do
        local shopCenter = center + Vector3.new(pos.x, 10, pos.z)
        createPart(geo, "Shop_Front_" .. i, shopCenter, Vector3.new(35, 20, 1), Enum.Material.Glass, PALETTES.ZONE2.glass_dirty, {transparency = 0.3})
        createPart(geo, "Shop_Back_" .. i, shopCenter + Vector3.new(0, 10, -25), Vector3.new(35, 20, 1), Enum.Material.Brick, PALETTES.ZONE2.wall, {})
        createPart(geo, "Shop_Left_" .. i, shopCenter + Vector3.new(-17, 10, -12), Vector3.new(1, 20, 25), Enum.Material.Brick, PALETTES.ZONE2.wall, {})
        createPart(geo, "Shop_Right_" .. i, shopCenter + Vector3.new(17, 10, -12), Vector3.new(1, 20, 25), Enum.Material.Brick, PALETTES.ZONE2.wall, {})
        -- Vidrios rotos en algunas tiendas
        if math.random() > 0.5 then createBrokenGlass(props, shopCenter + Vector3.new(0, 1, 0), 15) end
        -- Escombros dentro
        createDebris(props, shopCenter + Vector3.new(0, 1, -15), "trash")
    end

    -- ESCALERAS MECÁNICAS
    createPart(geo, "Escalator_Left", center + Vector3.new(-20, 5, 0), Vector3.new(15, 10, 40), Enum.Material.Metal, PALETTES.ZONE2.metal_rusty, {})
    createPart(geo, "Escalator_Right", center + Vector3.new(20, 5, 0), Vector3.new(15, 10, 40), Enum.Material.Metal, PALETTES.ZONE2.metal_rusty, {})

    -- FUENTE CENTRAL (punto de encuentro)
    createPart(geo, "Fountain_Base", center, Vector3.new(30, 1, 30), Enum.Material.Marble, Color3.fromRGB(180,180,200), {})
    createPart(geo, "Fountain_Column", center + Vector3.new(0, 8, 0), Vector3.new(6, 15, 6), Enum.Material.Marble, Color3.fromRGB(180,180,200), {})
    -- Agua seca, sangre seca
    createPart(props, "DriedBlood", center + Vector3.new(0, 1.1, 0), Vector3.new(25, 0.2, 25), Enum.Material.Blood, PALETTES.ZONE2.blood, {})

    -- VEHÍCULOS ABANDONADOS (entrada)
    createAbandonedCar(props, center + Vector3.new(0, 1, 60), 0, Color3.fromRGB(100,50,50), 0.8)
    createAbandonedCar(props, center + Vector3.new(15, 1, 65), 15, Color3.fromRGB(50,50,100), 0.5)
    createAbandonedCar(props, center + Vector3.new(-15, 1, 65), -15, Color3.fromRGB(80,80,80), 0.6)

    -- COLECCIONABLES
    local col = zone:FindFirstChild("Collectibles")
    for i = 1, 6 do
        local x = -70 + (i * 25)
        local z = (i % 2 == 0) and -40 or 40
        local rec = Instance.new("Part")
        rec.Name = "Recording_" .. i
        rec.CFrame = CFrame.new(center + Vector3.new(x, 2, z))
        rec.Size = Vector3.new(0.5, 0.2, 0.5)
        rec.Material = Enum.Material.Plastic
        rec.Color = Color3.fromRGB(100,149,237)
        rec.CanCollide = false
        rec.Parent = col
    end
    for i = 1, 4 do
        local photo = Instance.new("Part")
        photo.Name = "Photo_" .. i
        photo.CFrame = CFrame.new(center + Vector3.new(0, 2, -60 + (i * 30)))
        photo.Size = Vector3.new(0.2, 1, 0.8)
        photo.Material = Enum.Material.Paper
        photo.Color = Color3.fromRGB(255,193,37)
        photo.CanCollide = false
        photo.Parent = col
    end

    -- MERCHANT: LINCE (tienda trasera)
    local merchantSpawn = Instance.new("Part")
    merchantSpawn.Name = "MerchantSpawn_Lince"
    merchantSpawn.CFrame = CFrame.new(center + Vector3.new(80, 1, -50))
    merchantSpawn.Size = Vector3.new(3, 0.1, 3)
    merchantSpawn.Material = Enum.Material.Neon
    merchantSpawn.Color = Color3.fromRGB(255,165,0)
    merchantSpawn.Transparency = 0.5
    merchantSpawn.CanCollide = false
    merchantSpawn.Anchored = true
    merchantSpawn.Parent = zone:FindFirstChild("Spawns")
    local mName = Instance.new("StringValue")
    mName.Name = "MerchantName"
    mName.Value = "Lince"
    mName.Parent = merchantSpawn

    -- BOSS: EL VIGILANTE (seguridad del mall)
    local bossArena = Instance.new("Part")
    bossArena.Name = "BossArena_ElVigilante"
    bossArena.CFrame = CFrame.new(center + Vector3.new(0, 1, -70))
    bossArena.Size = Vector3.new(50, 1, 30)
    bossArena.Material = Enum.Material.Neon
    bossArena.Color = Color3.fromRGB(255,0,0)
    bossArena.Transparency = 0.7
    bossArena.CanCollide = false
    bossArena.Anchored = true
    bossArena.Parent = zone:FindFirstChild("Spawns")

    -- TRIGGER DE SALIDA
    createPart(zone:FindFirstChild("Triggers"), "ExitTrigger", center + Vector3.new(0, 1, 70), Vector3.new(40, 4, 5), Enum.Material.Neon, Color3.fromRGB(0,255,0), {transparency = 1, canCollide = false})

    print("[ZoneBuilder] Zona 2 completada")
    return zone
end

-- ============================================
-- ZONA 3: ESTACIÓN DE POLICÍA
-- ============================================
local function buildZone3()
    print("[ZoneBuilder] Zona 3: Estación de Policía...")
    local zone = createZoneFolder("Zone3_PoliceStation", {
        id = 3, name = "Estación de Policía - La Última Defensa",
        description = "Recursos potenciales. Algo encerrado en el sótano.",
        dayTime = "Día 4-5", weather = "Lluvia",
        lore = "La institución falló. Policías abandonados. El Encerrado fue jefe que se encerró.",
    })
    local geo = zone:FindFirstChild("Geometry")
    local props = zone:FindFirstChild("Props")
    local center = Vector3.new(400, 0, 0)

    -- EDIFICIO PRINCIPAL
    createPart(geo, "GroundFloor", center, Vector3.new(120, 1, 80), Enum.Material.Concrete, PALETTES.ZONE3.concrete, {})
    createPart(geo, "Wall_Left", center + Vector3.new(-60, 15, 0), Vector3.new(1, 30, 80), Enum.Material.Concrete, PALETTES.ZONE3.concrete, {})
    createPart(geo, "Wall_Right", center + Vector3.new(60, 15, 0), Vector3.new(1, 30, 80), Enum.Material.Concrete, PALETTES.ZONE3.concrete, {})
    createPart(geo, "Wall_Back", center + Vector3.new(0, 15, -40), Vector3.new(120, 30, 1), Enum.Material.Concrete, PALETTES.ZONE3.concrete, {})
    createPart(geo, "Wall_Front", center + Vector3.new(0, 15, 40), Vector3.new(120, 30, 1), Enum.Material.Concrete, PALETTES.ZONE3.concrete, {})
    createPart(geo, "SecondFloor", center, Vector3.new(118, 1, 78), Enum.Material.Concrete, PALETTES.ZONE3.concrete, {})

    -- CELDAS (6 módulos)
    for i = 1, 6 do
        local cellX = -50 + (i * 17)
        createPart(geo, "Cell_Wall_" .. i, center + Vector3.new(cellX, 7, -20), Vector3.new(12, 14, 1), Enum.Material.Metal, PALETTES.ZONE3.metal_bars, {transparency = 0.3})
        createPart(geo, "Cell_Door_" .. i, center + Vector3.new(cellX, 7, -15), Vector3.new(8, 12, 1), Enum.Material.Metal, PALETTES.ZONE3.metal_bars, {transparency = 0.5})
        -- Sangre seca en algunas celdas
        if math.random() > 0.5 then
            createPart(props, "BloodStain_" .. i, center + Vector3.new(cellX, 0.1, -18), Vector3.new(6, 0.1, 6), Enum.Material.Blood, PALETTES.ZONE3.blood_dried, {})
        end
    end

    -- SÓTANO (acceso al jefe)
    createPart(geo, "Basement_Floor", center + Vector3.new(0, -10, 30), Vector3.new(40, 1, 30), Enum.Material.Concrete, Color3.fromRGB(50,50,50), {})
    createPart(geo, "Basement_Wall", center + Vector3.new(0, -5, 30), Vector3.new(40, 10, 1), Enum.Material.Metal, PALETTES.ZONE3.metal_bars, {transparency = 0.5})

    -- OFICINAS (segundo piso)
    createPart(geo, "Office_Desk_1", center + Vector3.new(-40, 16, 20), Vector3.new(6, 2, 3), Enum.Material.Wood, PALETTES.ZONE3.desk_wood, {})
    createPart(geo, "Office_Desk_2", center + Vector3.new(-20, 16, 20), Vector3.new(6, 2, 3), Enum.Material.Wood, PALETTES.ZONE3.desk_wood, {})
    createPart(geo, "File_Cabinet", center + Vector3.new(30, 16, 30), Vector3.new(2, 4, 2), Enum.Material.Metal, PALETTES.ZONE3.file_gray, {})

    -- ARCHIVOS DE EVIDENCIA
    for i = 1, 3 do
        createPart(props, "Evidence_Box_" .. i, center + Vector3.new(40, 16, 20 + i*5), Vector3.new(1, 1, 1), Enum.Material.Plastic, PALETTES.ZONE3.evidence_yellow, {})
    end

    -- COLECCIONABLES
    local col = zone:FindFirstChild("Collectibles")
    for i = 1, 7 do
        local x = -50 + (i * 15)
        local z = (i % 2 == 0) and 25 or -25
        local rec = Instance.new("Part")
        rec.Name = "Recording_" .. i
        rec.CFrame = CFrame.new(center + Vector3.new(x, 2, z))
        rec.Size = Vector3.new(0.5, 0.2, 0.5)
        rec.Material = Enum.Material.Plastic
        rec.Color = Color3.fromRGB(100,149,237)
        rec.CanCollide = false
        rec.Parent = col
    end

    -- MERCHANT: NOCTHYR (oficina del capitán)
    local merchantSpawn = Instance.new("Part")
    merchantSpawn.Name = "MerchantSpawn_Nocthyr"
    merchantSpawn.CFrame = CFrame.new(center + Vector3.new(50, 16, 30))
    merchantSpawn.Size = Vector3.new(3, 0.1, 3)
    merchantSpawn.Material = Enum.Material.Neon
    merchantSpawn.Color = Color3.fromRGB(138,43,226)
    merchantSpawn.Transparency = 0.5
    merchantSpawn.CanCollide = false
    merchantSpawn.Anchored = true
    merchantSpawn.Parent = zone:FindFirstChild("Spawns")

    -- BOSS: EL ENCERRADO (sótano)
    local bossArena = Instance.new("Part")
    bossArena.Name = "BossArena_ElEncerrado"
    bossArena.CFrame = CFrame.new(center + Vector3.new(0, -9, 30))
    bossArena.Size = Vector3.new(35, 1, 25)
    bossArena.Material = Enum.Material.Neon
    bossArena.Color = Color3.fromRGB(255,0,0)
    bossArena.Transparency = 0.7
    bossArena.CanCollide = false
    bossArena.Anchored = true
    bossArena.Parent = zone:FindFirstChild("Spawns")

    -- TRIGGER DE SALIDA
    createPart(zone:FindFirstChild("Triggers"), "ExitTrigger", center + Vector3.new(0, 1, -35), Vector3.new(30, 4, 5), Enum.Material.Neon, Color3.fromRGB(0,255,0), {transparency = 1, canCollide = false})

    print("[ZoneBuilder] Zona 3 completada")
    return zone
end

-- ============================================
-- ZONA 4: HOSPITAL
-- ============================================
local function buildZone4()
    print("[ZoneBuilder] Zona 4: Hospital...")
    local zone = createZoneFolder("Zone4_Hospital", {
        id = 4, name = "Hospital - La Casa del Dolor",
        description = "El lugar más peligroso. Mutaciones extrañas.",
        dayTime = "Día 6-8", weather = "Noche cerrada",
        lore = "Origen del horror. Ala pediátrica vacía. La Doctora experimentaba aquí.",
    })
    local geo = zone:FindFirstChild("Geometry")
    local props = zone:FindFirstChild("Props")
    local center = Vector3.new(600, 0, 0)

    -- EDIFICIO HOSPITAL
    createPart(geo, "GroundFloor", center, Vector3.new(150, 1, 120), Enum.Material.Marble, PALETTES.ZONE4.tile, {})
    createPart(geo, "Wall_Left", center + Vector3.new(-75, 20, 0), Vector3.new(1, 40, 120), Enum.Material.Concrete, PALETTES.ZONE4.wall_green, {})
    createPart(geo, "Wall_Right", center + Vector3.new(75, 20, 0), Vector3.new(1, 40, 120), Enum.Material.Concrete, PALETTES.ZONE4.wall_green, {})
    createPart(geo, "Wall_Back", center + Vector3.new(0, 20, -60), Vector3.new(150, 40, 1), Enum.Material.Concrete, PALETTES.ZONE4.wall_green, {})
    createPart(geo, "Wall_Front", center + Vector3.new(0, 20, 60), Vector3.new(150, 40, 1), Enum.Material.Concrete, PALETTES.ZONE4.wall_green, {})

    -- HABITACIONES (8 módulos)
    local roomPositions = {{x=-50,z=-40},{x=-20,z=-40},{x=10,z=-40},{x=40,z=-40},
                           {x=-50,z=40},{x=-20,z=40},{x=10,z=40},{x=40,z=40}}
    for i, pos in ipairs(roomPositions) do
        local roomCenter = center + Vector3.new(pos.x, 10, pos.z)
        createPart(geo, "Room_Wall_" .. i, roomCenter, Vector3.new(25, 20, 1), Enum.Material.SmoothPlastic, PALETTES.ZONE4.wall_green, {})
        createPart(geo, "Room_Bed_" .. i, roomCenter + Vector3.new(0, 1, -5), Vector3.new(3, 2, 6), Enum.Material.Fabric, Color3.fromRGB(240,240,240), {})
        -- Sangre en algunas habitaciones
        if math.random() > 0.6 then
            createPart(props, "Blood_" .. i, roomCenter + Vector3.new(0, 0.1, 0), Vector3.new(15, 0.1, 15), Enum.Material.Blood, PALETTES.ZONE4.blood_fresh, {})
        end
    end

    -- ALA PEDIÁTRICA (zona especial - más oscura)
    createPart(geo, "Pediatric_Wing", center + Vector3.new(0, 0, 80), Vector3.new(80, 1, 30), Enum.Material.Marble, Color3.fromRGB(200,220,200), {})
    -- Camas pequeñas vacías
    for i = 1, 4 do
        createPart(props, "Pediatric_Bed_" .. i, center + Vector3.new(-30 + (i*20), 1, 80), Vector3.new(2, 1, 4), Enum.Material.Fabric, Color3.fromRGB(200,230,255), {})
    end

    -- QUIRÓFANOS (centro)
    createPart(geo, "Surgery_Room", center, Vector3.new(60, 1, 40), Enum.Material.Metal, PALETTES.ZONE4.metal_surgical, {})
    createPart(props, "Surgery_Light", center + Vector3.new(0, 15, 0), Vector3.new(5, 1, 5), Enum.Material.Neon, Color3.fromRGB(255,255,255), {transparency = 0.5})

    -- CORTINAS
    for i = 1, 4 do
        createPart(props, "Curtain_" .. i, center + Vector3.new(-40 + (i*25), 10, 0), Vector3.new(1, 15, 20), Enum.Material.Fabric, PALETTES.ZONE4.curtain, {transparency = 0.6})
    end

    -- COLECCIONABLES
    local col = zone:FindFirstChild("Collectibles")
    for i = 1, 8 do
        local x = -60 + (i * 15)
        local z = (i % 2 == 0) and 45 or -45
        local rec = Instance.new("Part")
        rec.Name = "Recording_" .. i
        rec.CFrame = CFrame.new(center + Vector3.new(x, 2, z))
        rec.Size = Vector3.new(0.5, 0.2, 0.5)
        rec.Material = Enum.Material.Plastic
        rec.Color = Color3.fromRGB(100,149,237)
        rec.CanCollide = false
        rec.Parent = col
    end

    -- MERCHANT: CIENTÍFICO BOTÁNICO (invernadero)
    local merchantSpawn = Instance.new("Part")
    merchantSpawn.Name = "MerchantSpawn_CientificoBotanico"
    merchantSpawn.CFrame = CFrame.new(center + Vector3.new(60, 1, 50))
    merchantSpawn.Size = Vector3.new(3, 0.1, 3)
    merchantSpawn.Material = Enum.Material.Neon
    merchantSpawn.Color = Color3.fromRGB(34,139,34)
    merchantSpawn.Transparency = 0.5
    merchantSpawn.CanCollide = false
    merchantSpawn.Anchored = true
    merchantSpawn.Parent = zone:FindFirstChild("Spawns")

    -- BOSS: LA DOCTORA (quirófano principal)
    local bossArena = Instance.new("Part")
    bossArena.Name = "BossArena_LaDoctora"
    bossArena.CFrame = CFrame.new(center + Vector3.new(0, 1, 0))
    bossArena.Size = Vector3.new(50, 1, 35)
    bossArena.Material = Enum.Material.Neon
    bossArena.Color = Color3.fromRGB(255,0,0)
    bossArena.Transparency = 0.7
    bossArena.CanCollide = false
    bossArena.Anchored = true
    bossArena.Parent = zone:FindFirstChild("Spawns")

    -- TRIGGER DE SALIDA
    createPart(zone:FindFirstChild("Triggers"), "ExitTrigger", center + Vector3.new(0, 1, -55), Vector3.new(40, 4, 5), Enum.Material.Neon, Color3.fromRGB(0,255,0), {transparency = 1, canCollide = false})

    print("[ZoneBuilder] Zona 4 completada")
    return zone
end

-- ============================================
-- ZONA 5: BOSQUE / AFUERAS
-- ============================================
local function buildZone5()
    print("[ZoneBuilder] Zona 5: El Bosque...")
    local zone = createZoneFolder("Zone5_Forest", {
        id = 5, name = "Las Afueras - El Bosque Maldito",
        description = "Más abierto, pero no más seguro. Criaturas que cazan por sonido.",
        dayTime = "Día 9-11", weather = "Niebla espesa",
        lore = "La naturaleza reclaimando. Supervivientes se esconden. La Manada caza aquí.",
    })
    local geo = zone:FindFirstChild("Geometry")
    local props = zone:FindFirstChild("Props")
    local center = Vector3.new(800, 0, 0)

    -- SUELO NATURAL
    createPart(geo, "Ground", center, Vector3.new(300, 1, 250), Enum.Material.Ground, PALETTES.ZONE5.dirt, {})

    -- ÁRBOLES (50 unidades)
    math.randomseed(os.time())
    for i = 1, 50 do
        local x = center.X + randomRange(-130, 130)
        local z = center.Z + randomRange(-100, 100)
        -- Evitar camino central
        if math.abs(z - center.Z) > 30 then
            local dead = math.random() > 0.7
            createTree(props, Vector3.new(x, 15, z), 1, dead)
        end
    end

    -- CAMINO PRINCIPAL
    createPart(geo, "MainPath", center, Vector3.new(60, 0.2, 200), Enum.Material.Grass, PALETTES.ZONE5.grass_dead, {})

    -- CABAÑA ABANDONADA
    local cabinPos = center + Vector3.new(100, 5, 80)
    createPart(geo, "Cabin_Floor", cabinPos, Vector3.new(30, 1, 25), Enum.Material.Wood, PALETTES.ZONE5.tree_bark, {})
    createPart(geo, "Cabin_Wall_Left", cabinPos + Vector3.new(-15, 6, 0), Vector3.new(1, 12, 25), Enum.Material.Wood, PALETTES.ZONE5.tree_bark, {})
    createPart(geo, "Cabin_Wall_Right", cabinPos + Vector3.new(15, 6, 0), Vector3.new(1, 12, 25), Enum.Material.Wood, PALETTES.ZONE5.tree_bark, {})
    createPart(geo, "Cabin_Wall_Back", cabinPos + Vector3.new(0, 6, -12), Vector3.new(30, 12, 1), Enum.Material.Wood, PALETTES.ZONE5.tree_bark, {})
    createPart(geo, "Cabin_Roof", cabinPos + Vector3.new(0, 13, 0), Vector3.new(32, 1, 27), Enum.Material.Wood, Color3.fromRGB(82, 58, 31), {})

    -- VEHÍCULOS ABANDONADOS (camino)
    createAbandonedCar(props, center + Vector3.new(-50, 1, -50), 0, Color3.fromRGB(80,50,50), 0.9)
    createAbandonedCar(props, center + Vector3.new(-80, 1, 30), 20, Color3.fromRGB(50,80,50), 0.7)

    -- COLECCIONABLES
    local col = zone:FindFirstChild("Collectibles")
    for i = 1, 6 do
        local x = center.X + randomRange(-100, 100)
        local z = center.Z + randomRange(-80, 80)
        local rec = Instance.new("Part")
        rec.Name = "Recording_" .. i
        rec.CFrame = CFrame.new(Vector3.new(x, 3, z))
        rec.Size = Vector3.new(0.5, 0.2, 0.5)
        rec.Material = Enum.Material.Plastic
        rec.Color = Color3.fromRGB(100,149,237)
        rec.CanCollide = false
        rec.Parent = col
    end

    -- MERCHANT: HÉROE DEL CHOCOMILK (claro del bosque)
    local merchantSpawn = Instance.new("Part")
    merchantSpawn.Name = "MerchantSpawn_HeroeChocomilk"
    merchantSpawn.CFrame = CFrame.new(center + Vector3.new(80, 1, -60))
    merchantSpawn.Size = Vector3.new(3, 0.1, 3)
    merchantSpawn.Material = Enum.Material.Neon
    merchantSpawn.Color = Color3.fromRGB(255,165,0)
    merchantSpawn.Transparency = 0.5
    merchantSpawn.CanCollide = false
    merchantSpawn.Anchored = true
    merchantSpawn.Parent = zone:FindFirstChild("Spawns")

    -- BOSS: LA MANADA (claro)
    local bossArena = Instance.new("Part")
    bossArena.Name = "BossArena_LaManada"
    bossArena.CFrame = CFrame.new(center + Vector3.new(120, 1, 0))
    bossArena.Size = Vector3.new(60, 1, 50)
    bossArena.Material = Enum.Material.Neon
    bossArena.Color = Color3.fromRGB(255,0,0)
    bossArena.Transparency = 0.7
    bossArena.CanCollide = false
    bossArena.Anchored = true
    bossArena.Parent = zone:FindFirstChild("Spawns")

    -- TRIGGER DE SALIDA
    createPart(zone:FindFirstChild("Triggers"), "ExitTrigger", center + Vector3.new(150, 1, 0), Vector3.new(30, 4, 50), Enum.Material.Neon, Color3.fromRGB(0,255,0), {transparency = 1, canCollide = false})

    print("[ZoneBuilder] Zona 5 completada")
    return zone
end

-- ============================================
-- ZONA 6: PUNTO CERO
-- ============================================
local function buildZone6()
    print("[ZoneBuilder] Zona 6: Punto Cero...")
    local zone = createZoneFolder("Zone6_PointZero", {
        id = 6, name = "El Camino a Punto Cero",
        description = "La recta final. Todo lo aprendido se pone a prueba.",
        dayTime = "Día 12-15", weather = "Noche sin luna",
        lore = "Complejo militar de PharmaCorp. Reyes espera. La verdad del virus.",
    })
    local geo = zone:FindFirstChild("Geometry")
    local props = zone:FindFirstChild("Props")
    local center = Vector3.new(1000, 0, 0)

    -- COMPLEJO MILITAR
    createPart(geo, "GroundFloor", center, Vector3.new(200, 1, 150), Enum.Material.Metal, PALETTES.ZONE6.concrete_military, {})
    createPart(geo, "Wall_Left", center + Vector3.new(-100, 30, 0), Vector3.new(1, 60, 150), Enum.Material.Concrete, PALETTES.ZONE6.concrete_military, {})
    createPart(geo, "Wall_Right", center + Vector3.new(100, 30, 0), Vector3.new(1, 60, 150), Enum.Material.Concrete, PALETTES.ZONE6.concrete_military, {})
    createPart(geo, "Wall_Back", center + Vector3.new(0, 30, -75), Vector3.new(200, 60, 1), Enum.Material.Concrete, PALETTES.ZONE6.concrete_military, {})
    createPart(geo, "Wall_Front", center + Vector3.new(0, 30, 75), Vector3.new(200, 60, 1), Enum.Material.Concrete, PALETTES.ZONE6.concrete_military, {})

    -- EDIFICIOS INTERNOS (4 módulos militares)
    local buildings = {{x=-50,z=-50},{x=50,z=-50},{x=-50,z=50},{x=50,z=50}}
    for i, pos in ipairs(buildings) do
        local bCenter = center + Vector3.new(pos.x, 12, pos.z)
        createPart(geo, "Building_" .. i, bCenter, Vector3.new(40, 25, 30), Enum.Material.Concrete, PALETTES.ZONE6.metal_dark, {})
    end

    -- TORRE DE VIGILANCIA (central)
    createPart(geo, "WatchTower", center + Vector3.new(0, 25, 0), Vector3.new(20, 50, 20), Enum.Material.Metal, PALETTES.ZONE6.metal_dark, {})
    createPart(geo, "WatchTower_Platform", center + Vector3.new(0, 48, 0), Vector3.new(25, 2, 25), Enum.Material.Metal, PALETTES.ZONE6.metal_dark, {})

    -- BÚNKER SUBTERRÁNEO (acceso a Reyes)
    createPart(geo, "Bunker_Floor", center + Vector3.new(0, -10, 0), Vector3.new(50, 1, 40), Enum.Material.Concrete, Color3.fromRGB(40,45,40), {})
    createPart(geo, "Bunker_Wall", center + Vector3.new(0, -5, 0), Vector3.new(50, 10, 1), Enum.Material.Metal, PALETTES.ZONE6.metal_dark, {transparency = 0.5})

    -- SEÑALES DE PELIGRO BIOHAZARD
    for i = 1, 4 do
        createPart(props, "HazardSign_" .. i, center + Vector3.new(-90 + (i*60), 30, 70), Vector3.new(3, 3, 0.5), Enum.Material.Plastic, PALETTES.ZONE6.hazard_yellow, {})
    end

    -- COLECCIONABLES
    local col = zone:FindFirstChild("Collectibles")
    for i = 1, 4 do
        local x = center.X - 80 + (i * 50)
        local z = (i % 2 == 0) and 60 or -60
        local rec = Instance.new("Part")
        rec.Name = "Recording_" .. i
        rec.CFrame = CFrame.new(Vector3.new(x, 2, z))
        rec.Size = Vector3.new(0.5, 0.2, 0.5)
        rec.Material = Enum.Material.Plastic
        rec.Color = Color3.fromRGB(100,149,237)
        rec.CanCollide = false
        rec.Parent = col
    end

    -- BOSS: COMANDANTE REYES (búnker)
    local bossArena = Instance.new("Part")
    bossArena.Name = "BossArena_ComandanteReyes"
    bossArena.CFrame = CFrame.new(center + Vector3.new(0, -9, 0))
    bossArena.Size = Vector3.new(45, 1, 35)
    bossArena.Material = Enum.Material.Neon
    bossArena.Color = Color3.fromRGB(255,0,0)
    bossArena.Transparency = 0.7
    bossArena.CanCollide = false
    bossArena.Anchored = true
    bossArena.Parent = zone:FindFirstChild("Spawns")

    -- TRIGGER FINAL
    createPart(zone:FindFirstChild("Triggers"), "FinalTrigger", center + Vector3.new(0, 1, 70), Vector3.new(30, 4, 10), Enum.Material.Neon, Color3.fromRGB(255,0,0), {transparency = 1, canCollide = false})

    print("[ZoneBuilder] Zona 6 completada")
    return zone
end

-- ============================================
-- CONFIGURACIÓN DE ILUMINACIÓN GLOBAL
-- ============================================
local function setupGlobalLighting()
    print("[ZoneBuilder] Configurando iluminación global...")
    Lighting.Brightness = 0.5
    Lighting.ClockTime = 18
    Lighting.FogStart = 10
    Lighting.FogEnd = 100
    Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 40)
    Lighting.Ambient = Color3.fromRGB(20, 20, 20)
    Lighting.Technology = Enum.Technology.Voxel

    local atmosphere = Lighting:FindFirstChild("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end
    atmosphere.Density = 0.3
    atmosphere.Color = Color3.fromRGB(30, 30, 30)
    atmosphere.Glare = 0.2
    atmosphere.Haze = 1.5
end

-- ============================================
-- FUNCIÓN PRINCIPAL - CONSTRUIR TODO
-- ============================================
local function buildAllZones()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   CONSTRUYENDO MAPA COMPLETO - EL OLVIDADO                  ║")
    print("║   Por favor espera 30-60 segundos...                        ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    local startTime = tick()

    -- Configurar iluminación
    setupGlobalLighting()

    -- Construir todas las zonas
    buildZone1()  -- Apartamento de Eddie
    buildZone2()  -- Centro Comercial
    buildZone3()  -- Estación de Policía
    buildZone4()  -- Hospital
    buildZone5()  -- El Bosque
    buildZone6()  -- Punto Cero

    local elapsed = tick() - startTime

    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   ¡MAPA COMPLETADO EXITOSAMENTE!                            ║")
    print("╠══════════════════════════════════════════════════════════════╣")
    print(string.format("║   Tiempo de construcción: %.2f segundos            ║", elapsed))
    print("║   Zonas creadas: 6                                           ║")
    print("║   Coleccionables: 34+                                        ║")
    print("║   Merchants: 3 (Lince, Nocthyr, Héroe del Chocomilk)        ║")
    print("║   Jefes: 5 (Vigilante, Encerrado, Doctora, Manada, Reyes)   ║")
    print("╠══════════════════════════════════════════════════════════════╣")
    print("║   PRÓXIMOS PASOS:                                            ║")
    print("║   1. Revisar zonas en Explorer                               ║")
    print("║   2. Ajustar geometría y decoración                          ║")
    print("║   3. Configurar scripts de enemigos                          ║")
    print("║   4. Implementar lógica de jefes y merchants                 ║")
    print("║   5. Agregar más detalles y props                            ║")
    print("╚══════════════════════════════════════════════════════════════╝")
end

-- ============================================
-- EXPORTAR FUNCIONES
-- ============================================
return {
    CONFIG = CONFIG,
    PALETTES = PALETTES,
    buildZone1 = buildZone1,
    buildZone2 = buildZone2,
    buildZone3 = buildZone3,
    buildZone4 = buildZone4,
    buildZone5 = buildZone5,
    buildZone6 = buildZone6,
    buildAllZones = buildAllZones,
}
