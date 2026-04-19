--[[
    BossSpawner
    Spawn y control de los 5 jefes principales
    Cada jefe con 2 fases y mecánicas únicas
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Utility = require(ReplicatedStorage.Modules.Utility)

local BossSpawner = {}

-- Configuración de los 5 jefes
local BOSSES = {
    Vigilante = {
        id = "Vigilante",
        name = "El Vigilante",
        zone = "Zone2",
        location = "Centro Comercial - Entrada principal",
        health = 500,
        phase1Health = 250,  -- 50%
        damage = 25,
        speed = 4,
        size = Vector3.new(4, 8, 4),
        color = Color3.fromRGB(30, 30, 50),
        abilities = {
            phase1 = {"Silbato", "Porra", "Grito"},
            phase2 = {"Furia", "Carga", "Golpe Masivo"},
        },
        weakPoints = {"head", "legs"},
        rewards = {
            xp = 100,
            item = "LlaveMall",
            morality = 5,
        },
        deathScene = "Cae de rodillas, el silbato rueda por el suelo",
    },

    Encerrado = {
        id = "Encerrado",
        name = "El Encerrado",
        zone = "Zone3",
        location = "Estación de Policía - Sótano",
        health = 800,
        phase1Health = 400,
        damage = 35,
        speed = 3,
        size = Vector3.new(5, 9, 5),
        color = Color3.fromRGB(20, 20, 20),
        abilities = {
            phase1 = {"Golpes Puerta", "Cadenas", "Embistida"},
            phase2 = {"Rugido", "Destructor", "Sin Piedad"},
        },
        weakPoints = {"torso", "arms"},
        rewards = {
            xp = 150,
            weapon = "Thunder12",
            morality = 5,
        },
        deathScene = "Se derrumba contra la celda que lo contenía",
    },

    Doctora = {
        id = "Doctora",
        name = "La Doctora",
        zone = "Zone4",
        location = "Hospital - Quirófano principal",
        health = 600,
        phase1Health = 300,
        damage = 30,
        speed = 5,
        size = Vector3.new(3, 7, 3),
        color = Color3.fromRGB(200, 200, 200),
        abilities = {
            phase1 = {"Instrumentos", "Jeringa", "Risa"},
            phase2 = {"Sierras", "Paciente Cero", "Inyección Letal"},
        },
        weakPoints = {"head", "hands"},
        rewards = {
            xp = 200,
            item = "InfusionBotanica",
            morality = 5,
        },
        deathScene = "Sus instrumentos caen. Silencio clínico.",
    },

    Manada = {
        id = "Manada",
        name = "La Manada",
        zone = "Zone5",
        location = "Bosque - Claro de cabañas",
        health = 900,  -- Total (300 x 3)
        phase1Health = 450,  -- Cuando muere el primero
        damage = 25,
        speed = 6,
        size = Vector3.new(3, 6, 3),
        color = Color3.fromRGB(80, 60, 40),
        count = 3,  -- 3 integrantes
        abilities = {
            phase1 = {"Aullido", "Ataque Coordinado", "Cerco"},
            phase2 = {"Furia Familiar", "Venganza", "Último Aliento"},
        },
        weakPoints = {"head", "torso"},
        rewards = {
            xp = 250,
            weapon = "Hunter338",
            morality = 5,
        },
        deathScene = "Los tres caen. Un último aullido en el viento.",
    },

    Reyes = {
        id = "Reyes",
        name = "Comandante Reyes",
        zone = "Zone6",
        location = "Punto Cero - Oficina del Comandante",
        health = 1000,
        phase1Health = 500,
        damage = 40,
        speed = 5,
        size = Vector3.new(4, 7, 4),
        color = Color3.fromRGB(50, 60, 50),
        abilities = {
            phase1 = {"Ordenes", "Disparos Precisos", "Táctica"},
            phase2 = {"Por Vael", "Última Resistencia", "Fanático"},
        },
        weakPoints = {"head", "chest"},
        rewards = {
            xp = 500,
            ending = "Desbloquea finales A, B, E, F",
            morality = 10,
        },
        deathScene = "Cae de pie. Uniforme impecable. Digno.",
    },
}

-- Estado
local activeBosses = {}
local defeatedBosses = {}

-- Inicializar
function BossSpawner.init()
    Utility.log("BossSpawner", "Inicializado con " .. tostring(#BOSSES) .. " jefes")
end

-- Spawnear jefe
function BossSpawner.spawn(bossId, customPosition)
    local bossConfig = BOSSES[bossId]
    if not bossConfig then
        Utility.error("BossSpawner", "Jefe no encontrado: " .. bossId)
        return nil
    end

    -- Verificar si ya fue derrotado
    if defeatedBosses[bossId] then
        Utility.warn("BossSpawner", bossId .. " ya fue derrotado")
        return nil
    end

    Utility.log("BossSpawner", "Spawn de " .. bossConfig.name)

    -- Crear modelo del jefe
    local boss = BossSpawner.createBossModel(bossConfig, customPosition)
    if not boss then
        return nil
    end

    -- Estado del jefe
    local bossState = {
        config = bossConfig,
        model = boss,
        currentHealth = bossConfig.health,
        phase = 1,
        isActive = true,
        target = nil,
        lastAbilityTime = 0,
    }

    table.insert(activeBosses, bossState)

    -- Notificar a todos los jugadores
    BossSpawner.notifyAll("bossSpawned", bossId, bossConfig.zone)

    return bossState
end

-- Crear modelo del jefe
function BossSpawner.createBossModel(config, customPosition)
    local model = Instance.new("Model")
    model.Name = config.name

    -- Parte principal
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = config.size
    rootPart.Color = config.color
    rootPart.Material = Enum.Material.Neon
    rootPart.CanCollide = true

    -- Posición
    if customPosition then
        rootPart.CFrame = CFrame.new(customPosition)
    else
        -- Posición default en la zona
        local zoneFolder = Workspace.Zones:FindFirstChild(config.zone)
        if zoneFolder and zoneFolder:FindFirstChild("BossSpawn") then
            rootPart.CFrame = zoneFolder.BossSpawn.CFrame
        else
            rootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end

    rootPart.Parent = model

    -- Humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = config.health
    humanoid.Health = config.health
    humanoid.WalkSpeed = config.speed
    humanoid.DisplayName = config.name

    -- Barra de salud visible
    humanoid.HealthDisplayDistance = 50

    humanoid.Parent = model

    -- Scripts del jefe
    local bossScript = Instance.new("LocalScript")
    bossScript.Name = "BossController"
    bossScript.Source = [[
        -- Controller script para el jefe
        -- Se implementa la lógica específica de cada jefe
    ]]
    bossScript.Parent = model

    model.Parent = Workspace.Zones[config.zone] or Workspace

    return model
end

-- Actualizar jefe (llamado desde el loop del servidor)
function BossSpawner.updateBoss(bossState, dt)
    if not bossState.isActive then return end

    local model = bossState.model
    if not model or not model:FindFirstChild("Humanoid") then
        bossState.isActive = false
        return
    end

    local humanoid = model.HumanoidRootPart
    local health = model:FindFirstChild("Humanoid")

    -- Verificar fase
    if bossState.phase == 1 and bossState.currentHealth <= bossState.config.phase1Health then
        BossSpawner.onPhaseChange(bossState, 2)
    end

    -- Verificar muerte
    if health and health.Health <= 0 then
        BossSpawner.onBossDefeated(bossState)
        return
    end

    bossState.currentHealth = health.Health

    -- Usar habilidad aleatoria
    local abilities = bossState.phase == 1 and
        bossState.config.abilities.phase1 or
        bossState.config.abilities.phase2

    if tick() - bossState.lastAbilityTime > 5 then  -- Cada 5 segundos
        local ability = Utility.randomChoice(abilities)
        BossSpawner.useAbility(bossState, ability)
        bossState.lastAbilityTime = tick()
    end
end

-- Cambio de fase
function BossSpawner.onPhaseChange(bossState, newPhase)
    bossState.phase = newPhase

    Utility.log("BossSpawner", bossState.config.name .. " cambió a fase " .. newPhase)

    -- Notificar jugadores
    BossSpawner.notifyAll("bossPhaseChange", bossState.config.id, newPhase)

    -- Efectos visuales
    if bossState.model then
        local rootPart = bossState.model:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Cambiar color para indicar fase 2
            rootPart.BrickColor = BrickColor.new("Bright red")
        end
    end
end

-- Usar habilidad
function BossSpawner.useAbility(bossState, abilityName)
    Utility.log("BossSpawner", bossState.config.name .. " usa: " .. abilityName)

    -- Efectos específicos por habilidad
    local effects = {
        -- Fase 1
        ["Silbato"] = {type = "sound", range = 50, effect = "stun"},
        ["Porra"] = {type = "melee", damage = 25},
        ["Grito"] = {type = "aoe", range = 20, effect = "fear"},
        ["Golpes Puerta"] = {type = "environment", effect = "shake"},
        ["Cadenas"] = {type = "projectile", damage = 20},
        ["Embistida"] = {type = "charge", damage = 30},
        ["Instrumentos"] = {type = "projectile", damage = 15},
        ["Jeringa"] = {type = "debuff", effect = "poison"},
        ["Risa"] = {type = "sound", effect = "confusion"},
        ["Aullido"] = {type = "sound", range = 100, effect = "spawn_minions"},
        ["Ataque Coordinado"] = {type = "multi_attack"},
        ["Cerco"] = {type = "movement", effect = "surround"},
        ["Ordenes"] = {type = "buff", effect = "summon_guards"},
        ["Disparos Precisos"] = {type = "ranged", damage = 35},
        ["Táctica"] = {type = "strategy", effect = "trap"},

        -- Fase 2
        ["Furia"] = {type = "buff", effect = "damage_double"},
        ["Carga"] = {type = "charge", damage = 50},
        ["Golpe Masivo"] = {type = "aoe", range = 15, damage = 40},
        ["Rugido"] = {type = "sound", range = 50, effect = "knockback"},
        ["Destructor"] = {type = "melee", damage = 60},
        ["Sin Piedad"] = {type = "buff", effect = "no_stagger"},
        ["Sierras"] = {type = "projectile", damage = 35},
        ["Paciente Cero"] = {type = "summon"},
        ["Inyección Letal"] = {type = "instant", chance = 0.1},
        ["Furia Familiar"] = {type = "all_attack"},
        ["Venganza"] = {type = "buff", effect = "speed_double"},
        ["Último Aliento"] = {type = "suicide", damage = 100},
        ["Por Vael"] = {type = "final_stand"},
        ["Última Resistencia"] = {type = "heal", amount = 100},
        ["Fanático"] = {type = "buff", effect = "immune_fear"},
    }

    local effect = effects[abilityName]
    if effect then
        -- Aplicar efecto
        BossSpawner.applyEffect(bossState, effect)
    end
end

-- Aplicar efecto de habilidad
function BossSpawner.applyEffect(bossState, effect)
    -- Implementación específica por tipo de efecto
    Utility.log("BossSpawner", "Efecto aplicado: " .. effect.type)

    -- Notificar server para aplicar daño/efectos
    local CombatEvent = ReplicatedStorage:FindFirstChild("CombatEvent")
    if CombatEvent then
        CombatEvent:FireAllClients("bossAbility", bossState.config.id, effect.type)
    end
end

-- Cuando el jefe es derrotado
function BossSpawner.onBossDefeated(bossState)
    local config = bossState.config

    Utility.log("BossSpawner", config.name .. " derrotado")

    -- Marcar como derrotado
    bossState.isActive = false
    defeatedBosses[config.id] = true

    -- Remover de activos
    for i, boss in ipairs(activeBosses) do
        if boss == bossState then
            table.remove(activeBosses, i)
            break
        end
    end

    -- Death scene
    Utility.log("BossSpawner", "Death scene: " .. config.deathScene)

    -- Recompensas
    BossSpawner.giveRewards(config)

    -- Notificar jugadores
    BossSpawner.notifyAll("bossDefeated", config.id)

    -- Limpiar modelo después de un tiempo
    if bossState.model then
        task.delay(30, function()
            if bossState.model then
                bossState.model:Destroy()
            end
        end)
    end
end

-- Dar recompensas
function BossSpawner.giveRewards(config)
    Utility.log("BossSpawner", "Recompensas: " .. tostring(config.rewards.xp) .. " XP")

    -- Notificar para XP
    local ProgressionEvent = ReplicatedStorage:FindFirstChild("ProgressionEvent")
    if ProgressionEvent then
        ProgressionEvent:FireAllClients("bossKilled", config.id, config.rewards.xp)
    end

    -- Notificar para moralidad
    local MoralityEvent = ReplicatedStorage:FindFirstChild("MoralityEvent")
    if MoralityEvent then
        MoralityEvent:FireAllClients("bossKilled", config.id, config.rewards.morality)
    end
end

-- Notificar a todos los jugadores
function BossSpawner.notifyAll(event, ...)
    local BossEvent = ReplicatedStorage:FindFirstChild("BossEvent")
    if BossEvent then
        BossEvent:FireAllClients(event, ...)
    end
end

-- Obtener jefe activo
function BossSpawner.getActiveBoss(bossId)
    for _, boss in ipairs(activeBosses) do
        if boss.config.id == bossId then
            return boss
        end
    end
    return nil
end

-- Obtener jefes derrotados
function BossSpawner.getDefeatedBosses()
    return defeatedBosses
end

-- Verificar si todos los jefes fueron derrotados
function BossSpawner.allBossesDefeated()
    return #defeatedBosses == #BOSSES
end

-- Resetear (para nueva partida)
function BossSpawner.reset()
    -- Limpiar activos
    for _, boss in ipairs(activeBosses) do
        if boss.model then
            boss.model:Destroy()
        end
    end

    activeBosses = {}
    defeatedBosses = {}

    Utility.log("BossSpawner", "Reset completado")
end

return BossSpawner
