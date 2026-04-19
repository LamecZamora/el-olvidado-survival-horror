--[[
    ProgressionManager
    Sistema de nivel oculto de Eddie
    3 niveles: Civil Puro → Sobreviviente → Curtido
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)

local ProgressionManager = {}

-- Configuración
local CONFIG = {
    LEVEL_1_THRESHOLD = 0,
    LEVEL_2_THRESHOLD = 100,
    LEVEL_3_THRESHOLD = 300,

    -- XP por acción
    XP_VALUES = {
        killCommon = 5,
        killCorredor = 8,
        killBlindado = 15,
        killAcechador = 12,
        killBoss = 50,
        completeZone = 30,
        findWeapon = 10,
        firstWeaponUse = 5,
        fire100Shots = 15,
        kill50Enemies = 25,
        surviveNoDamage = 8,
        completeQuest = 20,
        findCollectible = 3,
        listenRecording = 2,
        readFile = 2,
        viewPhoto = 1,
        findDiaryPart = 5,
        bossNoDeath = 25,
        bossNoHeal = 15,
        exploreArea = 10,
    },

    -- Monólogos por nivel y contexto
    MONOLOGUES = {
        Level1 = {
            firstShot = "¿Por qué tiembla tanto mi mano?",
            firstKill = "Cayó. Lo disparé. No siento... nada.",
            lowHealth = "No puedo... no puedo hacer esto.",
            findingAmmo = "Cada bala cuenta. Cada una.",
        },
        Level2 = {
            improved = "Empiezo a entender cómo funciona esto.",
            stable = "Ya no tiembla tanto.",
            questioning = "¿Cuántos llevo? ¿Cuántos maté?",
            parents = "Mis padres estarían... ¿orgullosos?",
        },
        Level3 = {
            veteran = "Sigo sin saber lo que hago. Pero funcionó.",
            automatic = "Ya no pienso. Solo... actúo.",
            identity = "¿Sigo siendo el mismo Eddie?",
            final = "Punto Cero. Aquí voy.",
        },
    },
}

-- Estado
local currentLevel = 1
local currentXP = 0
local stats = {
    enemiesKilled = 0,
    shotsFired = 0,
    zonesCompleted = 0,
    bossesDefeated = 0,
    collectiblesFound = 0,
    questsCompleted = 0,
}

-- Inicializar
function ProgressionManager.init()
    currentLevel = 1
    currentXP = 0
    stats = {
        enemiesKilled = 0,
        shotsFired = 0,
        zonesCompleted = 0,
        bossesDefeated = 0,
        collectiblesFound = 0,
        questsCompleted = 0,
    }

    Utility.log("ProgressionManager", "Inicializado - Nivel " .. currentLevel)
end

-- Agregar XP
function ProgressionManager.addXP(source, amount)
    if not amount then
        amount = CONFIG.XP_VALUES[source]
        if not amount then
            Utility.warn("ProgressionManager", "XP source desconocida: " .. tostring(source))
            return
        end
    end

    local oldXP = currentXP
    local oldLevel = currentLevel

    currentXP = currentXP + amount

    -- Verificar subida de nivel
    if currentLevel == 1 and currentXP >= CONFIG.LEVEL_2_THRESHOLD then
        currentLevel = 2
        ProgressionManager.onLevelUp(2)
    elseif currentLevel == 2 and currentXP >= CONFIG.LEVEL_3_THRESHOLD then
        currentLevel = 3
        ProgressionManager.onLevelUp(3)
    end

    -- Actualizar stats
    if source:find("kill") then
        stats.enemiesKilled = stats.enemiesKilled + 1
    elseif source == "fire100Shots" then
        stats.shotsFired = stats.shotsFired + 100
    elseif source:find("collectible") then
        stats.collectiblesFound = stats.collectiblesFound + 1
    elseif source:find("quest") then
        stats.questsCompleted = stats.questsCompleted + 1
    elseif source:find("Zone") then
        stats.zonesCompleted = stats.zonesCompleted + 1
    elseif source:find("Boss") then
        stats.bossesDefeated = stats.bossesDefeated + 1
    end

    Utility.log("ProgressionManager",
        string.format("XP: %s (+%d) | Total: %d -> %d | Nivel: %d",
        source, amount, oldXP, currentXP, currentLevel))

    -- Notificar server
    local ProgressionEvent = ReplicatedStorage:FindFirstChild("ProgressionEvent")
    if ProgressionEvent then
        ProgressionEvent:FireServer("addXP", source, amount, currentXP, currentLevel)
    end
end

-- Cuando sube de nivel
function ProgressionManager.onLevelUp(newLevel)
    Utility.log("ProgressionManager", "¡SUBIDA DE NIVEL! " .. (newLevel - 1) .. " → " .. newLevel)

    -- Obtener monólogo apropiado
    local monologueKey = "Level" .. newLevel
    local monologues = ProgressionManager.MONOLOGUES[monologueKey]

    if monologues then
        -- Elegir monólogo basado en contexto
        local context = ProgressionManager.getContext()
        local monologue = monologues[context] or monologues.improved

        -- Reproducir voz
        ProgressionManager.playMonologue(monologue)
    end

    -- Notificar UI
    local UIEvent = ReplicatedStorage:FindFirstChild("UIEvent")
    if UIEvent then
        UIEvent:FireClient("onLevelUp", newLevel, currentLevel)
    end
end

-- Obtener contexto actual para monólogo
function ProgressionManager.getContext()
    if stats.enemiesKilled == 0 then
        return "firstShot"
    elseif stats.enemiesKilled < 10 then
        return "firstKill"
    elseif stats.enemiesKilled < 50 then
        return "improved"
    else
        return "veteran"
    end
end

-- Reproducir monólogo
function ProgressionManager.playMonologue(text)
    Utility.log("ProgressionManager", "Monólogo: " .. text)

    local VoiceEvent = ReplicatedStorage:FindFirstChild("VoiceEvent")
    if VoiceEvent then
        VoiceEvent:FireClient("playMonologue", text)
    end
end

-- Obtener nivel actual
function ProgressionManager.getLevel()
    return currentLevel
end

-- Obtener XP actual
function ProgressionManager.getXP()
    return currentXP
end

-- Obtener progreso al siguiente nivel
function ProgressionManager.getProgressToNext()
    if currentLevel == 1 then
        return currentXP / CONFIG.LEVEL_2_THRESHOLD
    elseif currentLevel == 2 then
        return currentXP / CONFIG.LEVEL_3_THRESHOLD
    else
        return 1  -- Máximo nivel
    end
end

-- Obtener stats completos
function ProgressionManager.getStats()
    return {
        level = currentLevel,
        xp = currentXP,
        progress = ProgressionManager.getProgressToNext(),
        enemiesKilled = stats.enemiesKilled,
        shotsFired = stats.shotsFired,
        zonesCompleted = stats.zonesCompleted,
        bossesDefeated = stats.bossesDefeated,
        collectiblesFound = stats.collectiblesFound,
        questsCompleted = stats.questsCompleted,
    }
end

-- Verificar si puede usar arma (HEAVY 50 requiere Nivel 3)
function ProgressionManager.canUseWeapon(weaponId)
    local requirements = {
        ["Heavy50"] = 3,  -- Requiere Nivel 3
    }

    local requiredLevel = requirements[weaponId]
    if requiredLevel then
        return currentLevel >= requiredLevel
    end

    return true  -- Sin requisitos
end

-- Cargar desde guardado
function ProgressionManager.load(data)
    if data then
        currentLevel = data.eddieLevel or 1
        currentXP = data.xp or 0
        stats = data.stats or stats
        Utility.log("ProgressionManager", "Datos cargados - Nivel " .. currentLevel)
    end
end

-- Obtener datos para guardado
function ProgressionManager.getSaveData()
    return {
        eddieLevel = currentLevel,
        xp = currentXP,
        stats = Utility.deepCopy(stats),
    }
end

-- Reset para nueva partida
function ProgressionManager.reset()
    ProgressionManager.init()
    Utility.log("ProgressionManager", "Reset completado")
end

return ProgressionManager
