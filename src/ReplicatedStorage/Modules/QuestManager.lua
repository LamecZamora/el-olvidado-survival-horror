--[[
    QuestManager
    Sistema de misiones secundarias de los Trolelotes
    9 misiones totales (3 por cada Trolelote)
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)

local QuestManager = {}

-- Configuración de las 9 misiones
local QUESTS = {
    -- LINCE (M1, M4, M7)
    M1 = {
        id = "M1",
        giver = "Lince",
        title = "El Precio del Acero",
        description = "Lince necesita munición especial almacenada en el Hospital. Recupérala sin que te vean.",
        objective = "Recuperar munición AP del Hospital",
        location = "Zona 4 - Hospital",
        rewards = {
            weapon = "D19",
            ammo = 50,
            morality = 8,
        },
        steps = {
            "Habla con Lince en el Centro Comercial",
            "Viaja al Hospital (Zona 4)",
            "Encuentra el almacén de munición en el sótano",
            "Recupera la munición AP",
            "Regresa con Lince",
        },
        completed = false,
        rewardClaimed = false,
    },

    M4 = {
        id = "M4",
        giver = "Lince",
        title = "Protección Personal",
        description = "Un grupo de supervivientes necesita armas para defenderse. Equípalos.",
        objective = "Entregar 3 armas a supervivientes en el Mall",
        location = "Zona 2 - Centro Comercial",
        rewards = {
            weapon = "Milton9",
            mod = "Silenciador",
            morality = 8,
        },
        steps = {
            "Habla con Lince",
            "Encuentra al primer superviviente (planta baja)",
            "Encuentra al segundo superviviente (segunda planta)",
            "Encuentra al tercer superviviente (sótano)",
            "Regresa con Lince",
        },
        completed = false,
        rewardClaimed = false,
    },

    M7 = {
        id = "M7",
        giver = "Lince",
        title = "La Última Transacción",
        description = "Lince quiere que recuperes un arma especial antes de que Reyes la use.",
        objective = "Obtener la HEAVY 50 de la Estación de Policía",
        location = "Zona 3 - Estación de Policía",
        rewards = {
            weapon = "Heavy50",
            morality = 8,
            unlock = "Final A, B, C, D",
        },
        steps = {
            "Habla con Lince",
            "Infiltra la Estación de Policía",
            "Encuentra la oficina del jefe",
            "Recupera la HEAVY 50",
            "Decide: dársela a Lince o quedártela",
        },
        completed = false,
        rewardClaimed = false,
    },

    -- NOCTHYR (M2, M5, M8)
    M2 = {
        id = "M2",
        giver = "Nocthyr",
        title = "Sangre por Sangre",
        description = "Nocthyr necesita una muestra de sangre de un infectado especial para su investigación.",
        objective = "Obtener muestra de sangre de un Blindado",
        location = "Zona 3 - Estación de Policía",
        rewards = {
            item = "SangreNocthyr",
            venoms = {"Parálisis", "Sangrado"},
            morality = 8,
        },
        steps = {
            "Habla con Nocthyr en la Estación",
            "Encuentra un infectado Blindado",
            "Elimínalo sin dañar el cuerpo",
            "Extrae la muestra de sangre",
            "Regresa con Nocthyr",
        },
        completed = false,
        rewardClaimed = false,
    },

    M5 = {
        id = "M5",
        giver = "Nocthyr",
        title = "La Cura Imposible",
        description = "Un niño está infectado. Nocthyr cree que puede curarlo con su sangre, pero necesita ingredientes.",
        objective = "Recolectar plantas del bosque para la cura",
        location = "Zona 5 - El Bosque",
        rewards = {
            item = "InfusionBotanica",
            permanentBuff = "Resistencia +10%",
            morality = 8,
        },
        steps = {
            "Habla con Nocthyr",
            "Viaja al Bosque (Zona 5)",
            "Encuentra la Planta Lunar (cabaña norte)",
            "Encuentra la Raíz de Sangre (cabaña sur)",
            "Encuentra el Hongo Fantasma (cueva)",
            "Regresa con Nocthyr",
        },
        completed = false,
        rewardClaimed = false,
    },

    M8 = {
        id = "M8",
        giver = "Nocthyr",
        title = "El Origen de Todo",
        description = "Nocthyr quiere estudiar al Origen. Sobrevive al encuentro y obtén una muestra.",
        objective = "Sobrevivir al encuentro con El Origen y obtener muestra",
        location = "Zona 6 - Punto Cero",
        rewards = {
            item = "MuestraOrigen",
            morality = 8,
            unlock = "Final G (parcial)",
        },
        steps = {
            "Habla con Nocthyr",
            "Encuentra al Origen en el laboratorio",
            "Sobrevive al encuentro (no es necesario matar)",
            "Obtén la muestra de tejido",
            "Regresa con Nocthyr",
        },
        completed = false,
        rewardClaimed = false,
    },

    -- HÉROE DEL CHOCOMILK (M3, M6, M9)
    M3 = {
        id = "M3",
        giver = "El Héroe del Chocomilk",
        title = "El Mercader Anterior",
        description = "Antes que yo, hubo otro. Encuentra su diario y descubre qué le pasó.",
        objective = "Encontrar las 8 partes del diario del mercader anterior",
        location = "Todas las zonas",
        rewards = {
            item = "DiarioCompleto",
            morality = 8,
            unlock = "Final G (parcial)",
            lore = "Historia completa del Héroe anterior",
        },
        steps = {
            "Habla con el Héroe del Chocomilk",
            "Encuentra Parte 1 (Zona 1 - Apartamento)",
            "Encuentra Parte 2 (Zona 2 - Mall)",
            "Encuentra Parte 3 (Zona 3 - Policía)",
            "Encuentra Parte 4 (Zona 3 - Celda)",
            "Encuentra Parte 5 (Zona 4 - Hospital)",
            "Encuentra Parte 6 (Zona 5 - Cabaña)",
            "Encuentra Parte 7 (Zona 6 - Camino)",
            "Encuentra Parte 8 (Zona 6 - Laboratorio)",
            "Entrega el diario al Héroe",
        },
        completed = false,
        rewardClaimed = false,
    },

    M6 = {
        id = "M6",
        giver = "El Héroe del Chocomilk",
        title = "La Elección del Héroe",
        description = "Un grupo de supervivientes va a morir. Solo puedes salvar a algunos. Elige.",
        objective = "Salvar al menos 5 de 10 supervivientes en el Bosque",
        location = "Zona 5 - El Bosque",
        rewards = {
            permanentBuff = "Moralidad +15",
            morality = 8,
            unlock = "Final C (parcial)",
        },
        steps = {
            "Habla con el Héroe del Chocomilk",
            "Viaja al claro del Bosque",
            "Evalúa la situación (10 supervivientes rodeados)",
            "Salva al menos 5 (tu elección)",
            "Regresa con el Héroe",
        },
        completed = false,
        rewardClaimed = false,
    },

    M9 = {
        id = "M9",
        giver = "El Héroe del Chocomilk",
        title = "El Legado",
        description = "El Héroe quiere que tomes su lugar. Demuestra que puedes ser un mercader, no un héroe.",
        objective = "Completar las 8 misiones anteriores",
        location = "Zona 6 - Punto Cero",
        rewards = {
            title = "El Que Eligió Quedarse",
            morality = 8,
            unlock = "Final C",
            ending = "Te conviertes en el nuevo mercader",
        },
        steps = {
            "Completa M1, M2, M3, M4, M5, M6, M7, M8",
            "Habla con el Héroe del Chocomilk",
            "Acepta el legado",
            "Toma su lugar en la mesa",
        },
        completed = false,
        rewardClaimed = false,
    },
}

-- Estado
local activeQuest = nil
local completedQuests = {}

-- Inicializar
function QuestManager.init()
    activeQuest = nil
    completedQuests = {}

    Utility.log("QuestManager", "Inicializado con " .. tostring(#QUESTS) .. " misiones")
end

-- Obtener misión por ID
function QuestManager.getQuest(questId)
    return QUESTS[questId]
end

-- Obtener todas las misiones
function QuestManager.getAllQuests()
    return QUESTS
end

-- Obtener misiones de un Trolelote
function QuestManager.getQuestsByMerchant(merchant)
    local result = {}
    for id, quest in pairs(QUESTS) do
        if quest.giver == merchant then
            table.insert(result, quest)
        end
    end
    return result
end

-- Activar misión
function QuestManager.activateQuest(questId)
    local quest = QUESTS[questId]
    if not quest then
        return false, "Misión no encontrada"
    end

    if quest.completed then
        return false, "Misión ya completada"
    end

    activeQuest = questId
    Utility.log("QuestManager", "Misión activada: " .. quest.title)

    -- Notificar UI
    QuestManager.notifyUI("questActivated", questId)

    return true, nil
end

-- Actualizar progreso de misión
function QuestManager.updateQuestProgress(questId, step, completed)
    local quest = QUESTS[questId]
    if not quest then return false end

    -- Verificar si es la misión activa
    if activeQuest ~= questId then
        Utility.warn("QuestManager", "Misión no activa: " .. questId)
    end

    -- Marcar paso como completado
    if completed then
        Utility.log("QuestManager", "Paso completado: " .. step)

        -- Verificar si todos los pasos están completos
        local allComplete = true
        for i = 1, #quest.steps do
            if not quest.stepsCompleted[i] then
                allComplete = false
                break
            end
        end

        if allComplete then
            quest.completed = true
            table.insert(completedQuests, questId)
            Utility.log("QuestManager", "¡Misión completada: " .. quest.title .. "!")

            -- Notificar para moralidad
            local MoralityEvent = ReplicatedStorage:FindFirstChild("MoralityEvent")
            if MoralityEvent then
                MoralityEvent:FireServer("completeQuest", questId, quest.rewards.morality)
            end
        end
    end

    QuestManager.notifyUI("questProgress", questId)
    return true
end

-- Reclamar recompensa
function QuestManager.claimReward(questId)
    local quest = QUESTS[questId]
    if not quest then
        return false, "Misión no encontrada"
    end

    if not quest.completed then
        return false, "Misión no completada"
    end

    if quest.rewardClaimed then
        return false, "Recompensa ya reclamada"
    end

    -- Aplicar recompensas
    if quest.rewards.weapon then
        local InventoryManager = require(ReplicatedStorage.Modules.InventoryManager)
        InventoryManager.addWeapon(quest.rewards.weapon, 50, quest.rewards.mod and {quest.rewards.mod} or {})
    end

    if quest.rewards.item then
        local InventoryManager = require(ReplicatedStorage.Modules.InventoryManager)
        InventoryManager.addItem(quest.rewards.item, 1)
    end

    if quest.rewards.morality then
        local MoralityManager = require(ReplicatedStorage.Modules.MoralityManager)
        MoralityManager.addAction("completeQuest", quest.rewards.morality)
    end

    quest.rewardClaimed = true
    Utility.log("QuestManager", "Recompensa reclamada: " .. quest.title)

    QuestManager.notifyUI("rewardClaimed", questId)

    return true, quest.rewards
end

-- Verificar si todas las misiones están completas
function QuestManager.allQuestsComplete()
    local count = 0
    for id, quest in pairs(QUESTS) do
        if quest.completed then
            count = count + 1
        end
    end
    return count == 9
end

-- Obtener misiones completadas
function QuestManager.getCompletedQuests()
    return completedQuests
end

-- Obtener misión activa
function QuestManager.getActiveQuest()
    return activeQuest and QUESTS[activeQuest] or nil
end

-- Notificar UI
function QuestManager.notifyUI(event, data)
    local QuestEvent = ReplicatedStorage:FindFirstChild("QuestEvent")
    if QuestEvent then
        QuestEvent:FireClient("update", event, data)
    end
end

-- Obtener progreso total
function QuestManager.getProgress()
    local completed = 0
    for id, quest in pairs(QUESTS) do
        if quest.completed then
            completed = completed + 1
        end
    end

    return {
        total = 9,
        completed = completed,
        byMerchant = QuestManager.getByMerchant(),
    }
end

-- Obtener progreso por Trolelote
function QuestManager.getByMerchant()
    local result = {
        Lince = {completed = 0, total = 3},
        Nocthyr = {completed = 0, total = 3},
        Heroe = {completed = 0, total = 3},
    }

    for id, quest in pairs(QUESTS) do
        if quest.completed then
            if quest.giver == "Lince" then
                result.Lince.completed = result.Lince.completed + 1
            elseif quest.giver == "Nocthyr" then
                result.Nocthyr.completed = result.Nocthyr.completed + 1
            elseif quest.giver == "El Héroe del Chocomilk" then
                result.Heroe.completed = result.Heroe.completed + 1
            end
        end
    end

    return result
end

-- Cargar desde guardado
function QuestManager.load(data)
    if data then
        for id, questData in pairs(data) do
            if QUESTS[id] then
                QUESTS[id].completed = questData.completed or false
                QUESTS[id].rewardClaimed = questData.rewardClaimed or false
                if QUESTS[id].completed then
                    table.insert(completedQuests, id)
                end
            end
        end
        Utility.log("QuestManager", "Misiones cargadas")
    end
end

-- Obtener datos para guardado
function QuestManager.getSaveData()
    local data = {}
    for id, quest in pairs(QUESTS) do
        data[id] = {
            completed = quest.completed,
            rewardClaimed = quest.rewardClaimed,
        }
    end
    return data
end

return QuestManager
