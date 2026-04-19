--[[
    SaveManager
    Sistema de guardado con DataStore
    Maneja carga, guardado y recuperación de datos
--]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)

local SaveManager = {}

-- Configuración
local CONFIG = {
    DATASTORE_NAME = "ElOlvidado_SaveData_v1",
    MAX_RETRIES = 3,
    RETRY_DELAY = 1,
    VERSION = "1.0.0",
}

-- DataStore principal
local DataStore = DataStoreService:GetDataStore(CONFIG.DATASTORE_NAME)

-- Cache en memoria
local saveCache = {}
local pendingSaves = {}

-- Inicializar
function SaveManager.init()
    Utility.log("SaveManager", "Inicializado con DataStore: " .. CONFIG.DATASTORE_NAME)
end

-- Crear datos por defecto para nuevo jugador
function SaveManager.createDefaultData(player)
    local data = {
        -- PROGRESO
        currentZone = 1,
        currentDay = 1,
        playTime = 0,

        -- MORALIDAD
        moralityScore = 50,
        decisionsMade = {},

        -- INVENTARIO
        weapons = {
            {id = "HG18", ammo = 12, mods = {}},
        },
        items = {},

        -- COLECCIONABLES
        collectibles = {
            recordings = {},
            photos = {},
            files = {},
            diary = {},
        },

        -- MISIONES
        quests = {
            M1 = {completed = false, rewardClaimed = false},
            M2 = {completed = false, rewardClaimed = false},
            M3 = {completed = false, rewardClaimed = false},
            M4 = {completed = false, rewardClaimed = false},
            M5 = {completed = false, rewardClaimed = false},
            M6 = {completed = false, rewardClaimed = false},
            M7 = {completed = false, rewardClaimed = false},
            M8 = {completed = false, rewardClaimed = false},
            M9 = {completed = false, rewardClaimed = false},
        },

        -- PROGRESIÓN
        eddieLevel = 1,
        xp = 0,
        enemiesKilled = 0,
        shotsFired = 0,

        -- ZONAS
        zonesCompleted = {},
        bossesDefeated = {},

        -- ESTADÍSTICAS
        stats = {
            timePlayed = 0,
            distanceTraveled = 0,
            itemsFound = 0,
            npcsHelped = 0,
            npcsKilled = 0,
        },

        -- FINALES
        endingsUnlocked = {},
        playthroughs = 0,

        -- SETTINGS
        settings = {
            musicVolume = 0.5,
            sfxVolume = 0.5,
            voiceVolume = 0.5,
            sensitivity = 1.0,
        },

        -- METADATA
        lastSave = os.time(),
        version = CONFIG.VERSION,
    }

    return data
end

-- Cargar datos del jugador
function SaveManager.loadPlayerData(player)
    local userId = player.UserId
    local key = "player_" .. userId

    -- Verificar cache
    if saveCache[key] then
        Utility.log("SaveManager", "Datos cargados desde cache: " .. player.Name)
        return true, saveCache[key]
    end

    -- Intentar cargar de DataStore
    local success, data = Utility.retry(function()
        return DataStore:GetAsync(key)
    end, CONFIG.MAX_RETRIES, CONFIG.RETRY_DELAY)

    if not success then
        Utility.error("SaveManager", "Error al cargar datos: " .. tostring(data))
        return false, nil
    end

    -- Si no hay datos, crear nuevos
    if not data then
        Utility.log("SaveManager", "Jugador nuevo, creando datos: " .. player.Name)
        data = SaveManager.createDefaultData(player)
    else
        -- Migrar datos si hay versión diferente
        data = SaveManager.migrateData(data)
    end

    -- Guardar en cache
    saveCache[key] = data

    Utility.log("SaveManager", "Datos cargados exitosamente: " .. player.Name)
    return true, data
end

-- Guardar datos del jugador
function SaveManager.savePlayerData(player, data)
    local userId = player.UserId
    local key = "player_" .. userId

    -- Actualizar metadata
    data.lastSave = os.time()
    data.version = CONFIG.VERSION

    -- Agregar a pendientes
    pendingSaves[key] = {
        data = data,
        timestamp = os.time(),
        retries = 0,
    }

    -- Intentar guardar inmediatamente
    SaveManager.processPendingSaves()

    Utility.log("SaveManager", "Datos guardados: " .. player.Name)
    return true
end

-- Procesar guardados pendientes
function SaveManager.processPendingSaves()
    for key, saveData in pairs(pendingSaves) do
        local success, result = Utility.retry(function()
            return DataStore:SetAsync(key, saveData.data)
        end, CONFIG.MAX_RETRIES, CONFIG.RETRY_DELAY)

        if success then
            -- Actualizar cache
            saveCache[key] = saveData.data
            pendingSaves[key] = nil

            Utility.log("SaveManager", "Guardado completado: " .. key)
        else
            -- Incrementar reintentos
            saveData.retries = saveData.retries + 1

            if saveData.retries >= CONFIG.MAX_RETRIES then
                Utility.error("SaveManager", "Guardado fallido después de " ..
                    CONFIG.MAX_RETRIES .. " intentos: " .. key)
                pendingSaves[key] = nil
            end
        end
    end
end

-- Migrar datos de versiones anteriores
function SaveManager.migrateData(data)
    local oldVersion = data.version or "0.0.0"

    if oldVersion ~= CONFIG.VERSION then
        Utility.log("SaveManager", "Migrando datos de " .. oldVersion .. " a " .. CONFIG.VERSION)

        -- Ejemplo de migración
        if not data.collectibles then
            data.collectibles = {
                recordings = {},
                photos = {},
                files = {},
                diary = {},
            }
        end

        if not data.quests then
            data.quests = {}
            for i = 1, 9 do
                data.quests["M" .. i] = {completed = false, rewardClaimed = false}
            end
        end

        if not data.settings then
            data.settings = {
                musicVolume = 0.5,
                sfxVolume = 0.5,
                voiceVolume = 0.5,
                sensitivity = 1.0,
            }
        end

        data.version = CONFIG.VERSION
    end

    return data
end

-- Obtener datos de la cache (para acceso rápido)
function SaveManager.getCachedData(userId)
    local key = "player_" .. userId
    return saveCache[key]
end

-- Forzar guardado de todos los pendientes
function SaveManager.flushPendingSaves()
    SaveManager.processPendingSaves()
    Utility.log("SaveManager", "Flush completado, pendientes: " .. tostring(#pendingSaves))
end

-- Backup de emergencia (para uso manual)
function SaveManager.createBackup(player, data)
    local key = "backup_player_" .. player.UserId .. "_" .. os.time()

    local success, result = pcall(function()
        return DataStore:SetAsync(key, data)
    end)

    if success then
        Utility.log("SaveManager", "Backup creado: " .. key)
        return true, key
    else
        Utility.error("SaveManager", "Backup fallido: " .. tostring(result))
        return false, nil
    end
end

-- Restaurar desde backup
function SaveManager.restoreFromBackup(player, backupKey)
    local success, data = pcall(function()
        return DataStore:GetAsync(backupKey)
    end)

    if success and data then
        Utility.log("SaveManager", "Backup restaurado: " .. backupKey)
        return true, data
    else
        Utility.warn("SaveManager", "No se pudo restaurar backup: " .. backupKey)
        return false, nil
    end
end

-- Obtener estadísticas de guardado
function SaveManager.getStats()
    return {
        cacheSize = #saveCache,
        pendingSaves = #pendingSaves,
        dataStoreName = CONFIG.DATASTORE_NAME,
        version = CONFIG.VERSION,
    }
end

-- Inicializar al cargar
SaveManager.init()

return SaveManager
