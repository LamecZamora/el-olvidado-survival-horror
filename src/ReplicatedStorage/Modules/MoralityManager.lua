--[[
    MoralityManager
    Sistema de moralidad oculto - determina los 7 finales
    El jugador nunca ve este puntaje directamente
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)

local MoralityManager = {}

-- Configuración
local CONFIG = {
    BASE_SCORE = 50,           -- Puntaje inicial
    MIN_SCORE = 0,             -- Mínimo posible
    MAX_SCORE = 100,           -- Máximo posible

    -- Umbrales para finales
    THRESHOLDS = {
        FINAL_A = 80,          -- El Que Llegó (Muy Alta)
        FINAL_B = 60,          -- El Que Quedó Solo (Alta)
        FINAL_C = 70,          -- El Que Eligió Quedarse (Misiones)
        FINAL_D = 75,          -- La Cura (Sangre donada)
        FINAL_E = 30,          -- El Precio (Media-Baja)
        FINAL_F = 19,          -- El Origen (Muy Baja)
        -- FINAL_G es secreto (diario + decisión especial)
    },
}

-- Valores de acciones (categorizados)
local ACTION_VALUES = {
    -- NPCs (Supervivientes)
    SAVE_SURVIVOR = 5,
    GIVE_SUPPLIES = 3,
    SHARE_AMMO = 2,
    IGNORE_PLEA = -3,
    STEAL_SUPPLIES = -5,
    ABANDON_NPC = -7,
    KILL_NPC = -15,
    LISTEN_NPC = 2,
    INTERRUPT_NPC = -1,
    BREAK_PROMISE = -4,
    KEEP_PROMISE = 4,
    WARN_NPC = 3,
    USE_AS_BAIT = -10,
    DEFEND_NPC = 4,

    -- Trolelotes
    BUY_FROM_LINCE = 1,
    STEAL_FROM_LINCE = -10,
    ASK_ABOUT_MIMI_RESPECT = 2,
    INSIST_ABOUT_MIMI = -2,
    COMPLETE_LINCE_QUEST = 8,
    COMPLETE_NOCTHYR_QUEST = 8,
    COMPLETE_HERO_QUEST = 8,
    BUY_CURE = 1,
    ASK_REAL_NAME = -3,
    ACCEPT_VENOM = 2,
    USE_VENOM_ON_SURRENDERED = -5,
    COMPLETE_ALL_QUESTS = 15,
    BETRAY_TROLELOTE = -20,

    -- Enemigos (Infectados)
    KILL_COMMON = 0,
    USE_VENOM = -2,
    KILL_NON_THREAT = -3,
    USE_EXPLOSIVES = -1,
    CHECK_WAS_HUMAN = 2,
    FIND_PERSONAL_ITEM = 1,
    LEAVE_ITEM = 1,
    STEAL_ITEM = -2,
    USE_ITEM_AS_BAIT = -3,
    BURY_REMAINS = 3,
    BURN_REMAINS = 0,
    LEAVE_SUFFERING = -4,
    MERCY_KILL = 1,
    EXPERIMENT_ON = -5,

    -- Decisiones narrativas
    TELL_TRUTH = 3,
    LIE_TO_PROTECT = 2,
    LIE_FOR_BENEFIT = -4,
    STAY_SILENT = -2,
    SHARE_INFO = 3,
    HOARD_INFO = -1,
    SAVE_NPC_OVER_OBJECTIVE = 5,
    CHOOSE_OBJECTIVE_OVER_NPC = -5,
    FORGIVE_SURRENDERED = 6,
    EXECUTE_SURRENDERED = -8,
    LET_GO_SURRENDERED = 4,
    CAPTURE_FOR_INTERROGATION = -2,
    RELEASE_SCIENTIST = 3,
    KILL_SCIENTIST = -10,

    -- Coleccionables
    FIND_RECORDING = 1,
    LISTEN_RECORDING = 1,
    DESTROY_RECORDING = -2,
    COMPLETE_ZONE_RECORDINGS = 3,
    FIND_PHOTO = 1,
    VIEW_PHOTO = 1,
    COMPLETE_ZONE_FILES = 4,
    READ_FILE = 1,
    FIND_DIARY_PART = 2,
    READ_DIARY = 2,
    COMPLETE_DIARY_7_8 = 10,
    IGNORE_ALL_COLLECTIBLES = -5,

    -- Zonas únicas
    Z1_SAVE_NEIGHBOR = 5,
    Z1_LET_NEIGHBOR_TRANSFORM = -5,
    Z2_FORGIVE_THIEF = 4,
    Z2_EXECUTE_THIEF = -6,
    Z2_HELP_CLEAN_REFUGE = 3,
    Z3_FREE_PRISONER = 6,
    Z3_LEAVE_PRISONER = -3,
    Z3_FIND_CORRUPTION_EVIDENCE = 2,
    Z4_SAVE_SCIENTIST = 8,
    Z4_LET_SCIENTIST_DIE = -10,
    Z4_STEAL_RESEARCH = -5,
    Z4_SHARE_RESEARCH = 4,
    Z5_HELP_FOREST_SURVIVORS = 5,
    Z5_IGNORE_HELP_REQUEST = -4,
    Z5_FIND_CABIN = 2,
    Z5_RESPECT_CABIN = 3,
    Z5_LOOT_CABIN = -3,
    Z6_FORGIVE_REYES = 10,
    Z6_KILL_REYES = -5,
    Z6_FIND_PARENTS_FIRST = 5,
    Z6_FIND_LAB_FIRST = -3,
    Z6_DONATE_BLOOD = 15,
    Z6_REFUSE_BLOOD = -5,
    Z6_TAKE_LAB_CONTROL = -15,
    Z6_DESTROY_LAB = 5,
    Z6_TALK_TO_ORIGIN = 20,
    Z6_KILL_ORIGIN = -5,
    Z6_FREE_ORIGIN = 3,
}

-- Estado local (se sincroniza con server)
local currentScore = CONFIG.BASE_SCORE
local actionsTaken = {}
local specialFlags = {
    allQuestsComplete = false,
    diaryComplete = false,
    bloodDonated = false,
    labControlTaken = false,
    originTalked = false,
}

-- Inicializar
function MoralityManager.init()
    currentScore = CONFIG.BASE_SCORE
    actionsTaken = {}
    specialFlags = {
        allQuestsComplete = false,
        diaryComplete = false,
        bloodDonated = false,
        labControlTaken = false,
        originTalked = false,
    }

    Utility.log("MoralityManager", "Inicializado con puntaje base: " .. currentScore)
end

-- Aplicar acción de moralidad
function MoralityManager.addAction(actionName, value)
    if not value then
        value = ACTION_VALUES[actionName]
        if not value then
            Utility.warn("MoralityManager", "Acción desconocida: " .. tostring(actionName))
            return
        end
    end

    -- Registrar acción
    table.insert(actionsTaken, {
        action = actionName,
        value = value,
        timestamp = os.time(),
    })

    -- Aplicar al puntaje
    local oldScore = currentScore
    currentScore = Utility.clamp(currentScore + value, CONFIG.MIN_SCORE, CONFIG.MAX_SCORE)

    Utility.log("MoralityManager", string.format(
        "Acción: %s (%+d) -> Puntaje: %d -> %d",
        actionName, value, oldScore, currentScore
    ))

    -- Notificar al server para guardado
    local MoralityEvent = ReplicatedStorage:FindFirstChild("MoralityEvent")
    if MoralityEvent then
        MoralityEvent:FireServer("addAction", actionName, value, currentScore)
    end

    return currentScore
end

-- Obtener puntaje actual (oculto, solo para lógica interna)
function MoralityManager.getScore()
    return currentScore
end

-- Verificar umbral de final
function MoralityManager.checkFinal()
    local score = currentScore

    -- FINAL G (secreto) - prioridad máxima
    if specialFlags.diaryComplete and specialFlags.originTalked then
        return "G"
    end

    -- FINAL D (La Cura)
    if score >= CONFIG.THRESHOLDS.FINAL_D and specialFlags.bloodDonated then
        return "D"
    end

    -- FINAL C (El Que Eligió Quedarse)
    if score >= CONFIG.THRESHOLDS.FINAL_C and specialFlags.allQuestsComplete then
        return "C"
    end

    -- FINAL A (El Que Llegó)
    if score >= CONFIG.THRESHOLDS.FINAL_A then
        return "A"
    end

    -- FINAL B (El Que Quedó Solo)
    if score >= CONFIG.THRESHOLDS.FINAL_B then
        return "B"
    end

    -- FINAL F (El Origen)
    if score <= CONFIG.THRESHOLDS.FINAL_F then
        return "F"
    end

    -- FINAL E (El Precio) - default para moralidad media-baja
    return "E"
end

-- Establecer flags especiales
function MoralityManager.setFlag(flagName, value)
    if specialFlags[flagName] ~= nil then
        specialFlags[flagName] = value
        Utility.log("MoralityManager", string.format(
            "Flag establecida: %s = %s",
            flagName, tostring(value)
        ))

        -- Notificar al server
        local MoralityEvent = ReplicatedStorage:FindFirstChild("MoralityEvent")
        if MoralityEvent then
            MoralityEvent:FireServer("setFlag", flagName, value)
        end
    else
        Utility.warn("MoralityManager", "Flag desconocida: " .. tostring(flagName))
    end
end

-- Obtener flag
function MoralityManager.getFlag(flagName)
    return specialFlags[flagName]
end

-- Obtener resumen de acciones (para debugging)
function MoralityManager.getActionSummary()
    local summary = {}
    local positive = 0
    local negative = 0

    for _, action in ipairs(actionsTaken) do
        if action.value > 0 then
            positive = positive + action.value
        else
            negative = negative + action.value
        end
    end

    return {
        totalActions = #actionsTaken,
        positivePoints = positive,
        negativePoints = negative,
        finalScore = currentScore,
        flags = Utility.deepCopy(specialFlags),
    }
end

-- Resetear para nueva partida
function MoralityManager.reset()
    MoralityManager.init()
    Utility.log("MoralityManager", "Reset completado")
end

return MoralityManager
