--[[
    WeaponManager
    Estadísticas y configuración de todas las armas
    12 armas principales + modificadores
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)

local WeaponManager = {}

-- Configuración completa de armas
local WEAPONS = {
    -- PISTOLAS
    HG18 = {
        name = "HG-18",
        type = "pistol",
        caliber = ".38 Special",
        capacity = 12,
        damage = 25,
        accuracy = 0.85,
        recoil = 0.15,
        fireRate = 0.25,
        range = 50,
        reloadTime = 2.5,
        location = "Apartamento de Eddie (Zona 1)",
        description = "Pistola de uso policial. Primera arma de Eddie.",
        mods = {"Cargador ampliado", "Silenciador", "Mira láser", "Gatillo mejorado"},
    },

    D19 = {
        name = "D-19",
        type = "pistol",
        caliber = "9mm Parabellum",
        capacity = 7,
        damage = 40,
        accuracy = 0.75,
        recoil = 0.25,
        fireRate = 0.2,
        range = 40,
        reloadTime = 2.3,
        location = "Estación de Policía (Zona 3)",
        description = "Daño elevado, más retroceso. Ideal para lugares cerrados.",
        mods = {"Cargador ampliado", "Silenciador", "Empuñadura ergonómica"},
    },

    Milton9 = {
        name = "MILTON-9",
        type = "revolver",
        caliber = "Revólver 9mm",
        capacity = 6,
        damage = 45,
        accuracy = 0.88,
        recoil = 0.3,
        fireRate = 0.4,
        range = 45,
        reloadTime = 3.5,
        location = "Centro Comercial (Zona 2)",
        description = "Eficiente, resistente. Recarga lenta pero existe modificador.",
        mods = {"Tambor ampliado", "Cañón alargado", "Modificador de recarga rápida"},
    },

    MGUltra = {
        name = "MG-ULTRA",
        type = "revolver",
        caliber = ".44 Magnum",
        capacity = 6,
        damage = 85,
        accuracy = 0.82,
        recoil = 0.6,
        fireRate = 0.45,
        range = 55,
        reloadTime = 3.8,
        location = "Hospital (Zona 4)",
        description = "Poder devastador. Retroceso muy elevado.",
        mods = {"Tambor ampliado", "Compensador de retroceso", "Mira óptica pequeña"},
    },

    -- ESCOPETAS
    Thunder12 = {
        name = "THUNDER 12",
        type = "shotgun",
        caliber = "Calibre 12",
        capacity = 5,
        damage = 70,
        accuracy = 0.4,
        recoil = 0.4,
        fireRate = 0.6,
        range = 15,
        reloadTime = 0.8,
        location = "Estación de Policía (Zona 3)",
        description = "Cañón largo para mayor alcance. De cerca pulveriza.",
        mods = {"Tubo ampliado", "Culata acolchada", "Cañón recortado"},
        pelletCount = 8,
    },

    VarP = {
        name = "VAR-P",
        type = "shotgun_double",
        caliber = "Calibre 12",
        capacity = 2,
        damage = 95,
        accuracy = 0.35,
        recoil = 0.7,
        fireRate = 0.3,
        range = 12,
        reloadTime = 2.5,
        location = "Cabaña del bosque (Zona 5)",
        description = "Acabado clásico. Poco munición pero definitivo.",
        mods = {"Gatillo mejorado", "Culata de madera tallada"},
        pelletCount = 12,
    },

    -- RIFLES
    Hunter338 = {
        name = "HUNTER-338",
        type = "rifle",
        caliber = ".338 Lapua Magnum",
        capacity = 5,
        damage = 75,
        accuracy = 0.92,
        recoil = 0.5,
        fireRate = 0.8,
        range = 150,
        reloadTime = 2.8,
        location = "Afueras (Zona 5)",
        description = "Para mantener distancia. Requiere pulso firme.",
        mods = {"Mira telescópica 4x", "Bipode", "Silenciador subsónico"},
    },

    EagleEye = {
        name = "EAGLE EYE",
        type = "sniper",
        caliber = ".380 ACP",
        capacity = 1,
        damage = 55,
        accuracy = 0.98,
        recoil = 0.2,
        fireRate = 1.5,
        range = 200,
        reloadTime = 2.0,
        location = "Torre de vigilancia (Zona 5)",
        description = "Mira óptica. Derriba enemigos a larga distancia.",
        mods = {"Mira telescópica 8x", "Silenciador integrado", "Bipode ajustable"},
    },

    -- ARMAS ESPECIALES
    Heavy50 = {
        name = "HEAVY 50",
        type = "heavy_pistol",
        caliber = ".50 BMG",
        capacity = 7,
        damage = 100,
        accuracy = 0.7,
        recoil = 0.9,
        fireRate = 0.5,
        range = 80,
        reloadTime = 3.0,
        location = "Estación de Policía (Zona 3)",
        description = "Pistola pesada calibre .50 perforante.",
        mods = {},
        requirement = {eddieLevel = 3},  -- Requiere Nivel 3
        warning = "Puede lesionar las muñecas de Eddie sin experiencia",
    },

    Coil33X = {
        name = "COIL-33X",
        type = "energy",
        caliber = "Proyectil magnético",
        capacity = 1,
        damage = 100,
        accuracy = 0.8,
        recoil = 0,
        fireRate = 3.0,
        range = 60,
        reloadTime = 5.0,
        location = "Ala botánica (Zona 4)",
        description = "Arma electromagnética. Daño colateral.",
        mods = {"Batería ampliada", "Bobinas de cobre mejoradas"},
        ammoType = "battery",
        batteryCost = 3,
        areaDamage = true,
    },

    BreakerGun = {
        name = "BREAKER GUN",
        type = "special_pistol",
        caliber = "9mm modificado",
        capacity = 3,
        damage = 70,
        accuracy = 0.85,
        recoil = 0.35,
        fireRate = 0.3,
        range = 50,
        reloadTime = 2.5,
        location = "Hospital (Zona 4)",
        description = "Perfora hasta 3 cabezas en línea recta.",
        mods = {"Cargador ampliado", "Modificador de perforación doble"},
        penetration = 3,  -- Atraviesa 3 enemigos
    },

    -- CUERPO A CUERPO
    TacticalKnife = {
        name = "Cuchillo Táctico",
        type = "melee",
        damage = 20,
        attackSpeed = 0.4,
        range = 3,
        stealth = 0.9,
        location = "Centro Comercial (Zona 2)",
        description = "Silencioso pero requiere cercanía.",
        mods = {"Hoja afilada", "Empuñadura ergonómica", "Veneno aplicable"},
    },

    FireAxe = {
        name = "Hacha de Bombero",
        type = "melee_heavy",
        damage = 60,
        attackSpeed = 1.2,
        range = 4,
        stealth = 0.2,
        location = "Estación de Policía (Zona 3)",
        description = "Daño alto pero lenta. Rompe puertas.",
        mods = {"Hoja afilada", "Mango reforzado"},
        breaksDoors = true,
    },

    Crowbar = {
        name = "Palanca de Metal",
        type = "melee",
        damage = 30,
        attackSpeed = 0.7,
        range = 5,
        stealth = 0.4,
        location = "Apartamento (Zona 1)",
        description = "Equilibrada pero modesta.",
        mods = {},
        opensDoors = true,
    },
}

-- Tipos de munición
local AMMO_TYPES = {
    _38 = {
        name = ".38 Special",
        damage = 1.0,
        compatibleWeapons = {"HG18"},
    },
    _9mm = {
        name = "9mm Parabellum",
        damage = 1.1,
        compatibleWeapons = {"D19", "Milton9", "BreakerGun"},
    },
    _44 = {
        name = ".44 Magnum",
        damage = 1.5,
        compatibleWeapons = {"MGUltra"},
    },
    _12gauge = {
        name = "Calibre 12",
        damage = 1.2,
        compatibleWeapons = {"Thunder12", "VarP"},
    },
    _338 = {
        name = ".338 Lapua",
        damage = 1.4,
        compatibleWeapons = {"Hunter338"},
    },
    _380 = {
        name = ".380 ACP",
        damage = 1.0,
        compatibleWeapons = {"EagleEye"},
    },
    _50bmg = {
        name = ".50 BMG",
        damage = 2.0,
        compatibleWeapons = {"Heavy50"},
    },
    battery = {
        name = "Batería",
        damage = 1.0,
        compatibleWeapons = {"Coil33X"},
    },
}

-- Munición especial
local SPECIAL_AMMO = {
    AP = {
        name = "Balas AP",
        modifier = 1.3,
        effect = "Perfora armadura ligera",
        rarity = "Moderada",
        compatibleCalibers = {".38 Special", "9mm Parabellum"},
    },
    Explosive = {
        name = "Balas Explosivas",
        modifier = 1.5,
        effect = "Daño por explosión",
        rarity = "Rara",
        compatibleCalibers = {".44 Magnum", "Calibre 12"},
    },
    Incendiary = {
        name = "Balas Incendiarias",
        modifier = 1.2,
        effect = "Incendia objetivo",
        rarity = "Rara",
        compatibleCalibers = {"9mm Parabellum", ".338 Lapua"},
    },
    Subsonic = {
        name = "Balas Subsónicas",
        modifier = 0.9,
        effect = "Silenciosas + sigilo",
        rarity = "Común",
        compatibleCalibers = {"9mm Parabellum", ".380 ACP"},
    },
    HollowPoint = {
        name = "Balas Huecas",
        modifier = 1.4,
        effect = "Daño aumentado",
        rarity = "Común",
        compatibleCalibers = {".38 Special", "9mm Parabellum"},
    },
    Tracer = {
        name = "Balas Trazadoras",
        modifier = 1.0,
        effect = "Visibilidad nocturna",
        rarity = "Moderada",
        compatibleCalibers = {".44 Magnum", ".338 Lapua"},
    },
}

-- Obtener configuración de arma
function WeaponManager.getWeapon(weaponId)
    return WEAPONS[weaponId]
end

-- Obtener todas las armas
function WeaponManager.getAllWeapons()
    return WEAPONS
end

-- Obtener armas por tipo
function WeaponManager.getWeaponsByType(type)
    local result = {}
    for id, weapon in pairs(WEAPONS) do
        if weapon.type == type then
            table.insert(result, {id = id, weapon = weapon})
        end
    end
    return result
end

-- Calcular daño con modificadores
function WeaponManager.calculateDamage(weaponId, ammoType, hitZone, distance)
    local weapon = WEAPONS[weaponId]
    if not weapon then return 0 end

    local baseDamage = weapon.damage

    -- Modificador de munición
    if ammoType and SPECIAL_AMMO[ammoType] then
        baseDamage = baseDamage * SPECIAL_AMMO[ammoType].modifier
    end

    -- Multiplicador por zona del cuerpo
    local zoneMultipliers = {
        head = 2.5,
        torso = 1.5,
        limbs = 1.0,
    }
    local zoneMult = zoneMultipliers[hitZone] or 1.0

    -- Falloff por distancia
    local distanceFalloff = 1.0
    if distance and distance > weapon.range then
        distanceFalloff = weapon.range / distance
    end

    local finalDamage = baseDamage * zoneMult * distanceFalloff
    return math.floor(finalDamage)
end

-- Verificar si el jugador puede usar el arma
function WeaponManager.canUseWeapon(weaponId, playerLevel)
    local weapon = WEAPONS[weaponId]
    if not weapon then return false, "Arma no encontrada" end

    if weapon.requirement and weapon.requirement.eddieLevel then
        if playerLevel < weapon.requirement.eddieLevel then
            return false, "Requiere Nivel " .. weapon.requirement.eddieLevel
        end
    end

    return true, nil
end

-- Obtener modificadores disponibles para un arma
function WeaponManager.getAvailableMods(weaponId)
    local weapon = WEAPONS[weaponId]
    if not weapon then return {} end
    return weapon.mods or {}
end

-- Obtener tipo de munición
function WeaponManager.getAmmoType(ammoId)
    return AMMO_TYPES[ammoId]
end

-- Obtener munición especial
function WeaponManager.getSpecialAmmo(ammoId)
    return SPECIAL_AMMO[ammoId]
end

-- Obtener armas compatibles con munición
function WeaponManager.getCompatibleWeapons(ammoId)
    local ammoType = AMMO_TYPES[ammoId]
    if not ammoType then return {} end

    local result = {}
    for id, weapon in pairs(WEAPONS) do
        for _, compatible in ipairs(ammoType.compatibleWeapons) do
            if id == compatible then
                table.insert(result, id)
            end
        end
    end
    return result
end

-- Calcular tiempo de recarga con modificadores
function WeaponManager.getReloadTime(weaponId, hasQuickReload)
    local weapon = WEAPONS[weaponId]
    if not weapon then return 0 end

    local reloadTime = weapon.reloadTime
    if hasQuickReload then
        reloadTime = reloadTime * 0.7  -- 30% más rápido
    end
    return reloadTime
end

-- Obtener estadísticas para UI
function WeaponManager.getStats(weaponId)
    local weapon = WEAPONS[weaponId]
    if not weapon then return nil end

    return {
        name = weapon.name,
        type = weapon.type,
        damage = weapon.damage,
        accuracy = math.floor(weapon.accuracy * 100),
        recoil = math.floor(weapon.recoil * 100),
        fireRate = math.floor(60 / weapon.fireRate),  -- RPM
        range = weapon.range,
        capacity = weapon.capacity,
        reloadTime = weapon.reloadTime,
    }
end

return WeaponManager
