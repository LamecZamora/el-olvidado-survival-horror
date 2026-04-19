--[[
    EnemyAI
    IA de infectados - Pathfinding y estados de comportamiento
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Utility = require(ReplicatedStorage.Modules.Utility)

local EnemyAI = {}

-- Configuración
local CONFIG = {
    DETECTION_RANGE = {
        Common = 30,
        Corredor = 50,
        Blindado = 35,
        Acechador = 15,
    },
    HEARING_RANGE = {
        Common = 15,
        Corredor = 25,
        Blindado = 20,
        Acechador = 5,
    },
    ATTACK_DAMAGE = {
        Common = 15,
        Corredor = 20,
        Blindado = 30,
        Acechador = 25,
    },
    ATTACK_COOLDOWN = 1.5,
    PATH_RECALCULATE_TIME = 3,
}

-- Estados de IA
local AI_STATE = {
    IDLE = "idle",
    ALERT = "alert",
    CHASE = "chase",
    ATTACK = "attack",
    RETURN = "return",
}

-- Crear nuevo enemigo
function EnemyAI.createEnemy(enemyType, position, properties)
    local enemy = {
        type = enemyType or "Common",
        state = AI_STATE.IDLE,
        position = position,
        homePosition = position,
        targetPosition = nil,
        targetPlayer = nil,
        health = 100,
        speed = 4,
        damage = CONFIG.ATTACK_DAMAGE[enemyType] or 15,
        lastAttackTime = 0,
        lastPathCalculation = 0,
        path = nil,
        currentPathIndex = 0,
        properties = properties or {},
    }

    -- Aplicar configuraciones específicas por tipo
    EnemyAI.applyTypeConfig(enemy)

    return enemy
end

-- Aplicar configuración por tipo
function EnemyAI.applyTypeConfig(enemy)
    local configs = {
        Common = {
            health = 100,
            speed = 4,
            damage = 15,
            detectionRange = 30,
            hearingRange = 15,
        },
        Corredor = {
            health = 70,
            speed = 8,
            damage = 20,
            detectionRange = 50,
            hearingRange = 25,
        },
        Blindado = {
            health = 200,
            speed = 3,
            damage = 30,
            detectionRange = 35,
            hearingRange = 20,
            armorPoints = {"torso", "head"},  -- Puntos débiles
        },
        Acechador = {
            health = 80,
            speed = 5,
            damage = 25,
            detectionRange = 15,
            hearingRange = 5,
            stealth = true,
        },
    }

    local config = configs[enemy.type]
    if config then
        enemy.health = config.health
        enemy.speed = config.speed
        enemy.damage = config.damage
        enemy.detectionRange = config.detectionRange
        enemy.hearingRange = config.hearingRange

        for key, value in pairs(config) do
            if enemy.properties[key] == nil then
                enemy.properties[key] = value
            end
        end
    end
end

-- Actualizar enemigo (llamado cada frame)
function EnemyAI.update(enemy, dt, playerPosition)
    if not playerPosition then
        if enemy.state == AI_STATE.CHASE or enemy.state == AI_STATE.ALERT then
            enemy.state = AI_STATE.RETURN
        end
    end

    -- Máquina de estados
    if enemy.state == AI_STATE.IDLE then
        EnemyAI.updateIdle(enemy, dt, playerPosition)
    elseif enemy.state == AI_STATE.ALERT then
        EnemyAI.updateAlert(enemy, dt, playerPosition)
    elseif enemy.state == AI_STATE.CHASE then
        EnemyAI.updateChase(enemy, dt, playerPosition)
    elseif enemy.state == AI_STATE.ATTACK then
        EnemyAI.updateAttack(enemy, dt, playerPosition)
    elseif enemy.state == AI_STATE.RETURN then
        EnemyAI.updateReturn(enemy, dt)
    end

    -- Limitar cálculo de path
    if tick() - enemy.lastPathCalculation > CONFIG.PATH_RECALCULATE_TIME then
        enemy.path = nil
    end
end

-- Estado IDLE
function EnemyAI.updateIdle(enemy, dt, playerPosition)
    -- Patrullar área aleatoria
    if not enemy.targetPosition or Utility.distance(enemy.position, enemy.targetPosition) < 2 then
        -- Elegir nuevo punto aleatorio cerca de homePosition
        local angle = math.random() * math.pi * 2
        local distance = math.random(5, 15)
        enemy.targetPosition = enemy.homePosition + Vector3.new(
            math.cos(angle) * distance,
            0,
            math.sin(angle) * distance
        )
    end

    -- Mover hacia target
    EnemyAI.moveTo(enemy, enemy.targetPosition, dt)

    -- Detectar jugador
    if playerPosition then
        local dist = Utility.distance(enemy.position, playerPosition)
        if dist <= enemy.detectionRange then
            enemy.state = AI_STATE.ALERT
            enemy.targetPlayer = playerPosition
            Utility.log("EnemyAI", enemy.type .. " entró en estado ALERT")
        end
    end
end

-- Estado ALERT
function EnemyAI.updateAlert(enemy, dt, playerPosition)
    if not playerPosition then
        enemy.state = AI_STATE.IDLE
        return
    end

    -- Mirar hacia el jugador
    local direction = (playerPosition - enemy.position).Unit
    enemy.position = enemy.position + direction * enemy.speed * dt * 0.5

    -- Verificar línea de visión
    if Utility.hasLineOfView(enemy.position, playerPosition, {}) then
        local dist = Utility.distance(enemy.position, playerPosition)
        if dist <= enemy.detectionRange then
            enemy.state = AI_STATE.CHASE
            Utility.log("EnemyAI", enemy.type .. " entró en estado CHASE")
        end
    end

    -- Timeout de alerta
    enemy.alertTime = (enemy.alertTime or 0) + dt
    if enemy.alertTime > 5 then
        enemy.state = AI_STATE.IDLE
        enemy.alertTime = 0
    end
end

-- Estado CHASE
function EnemyAI.updateChase(enemy, dt, playerPosition)
    if not playerPosition then
        enemy.state = AI_STATE.RETURN
        return
    end

    local dist = Utility.distance(enemy.position, playerPosition)

    -- Calcular path si es necesario
    if not enemy.path or tick() - enemy.lastPathCalculation > CONFIG.PATH_RECALCULATE_TIME then
        enemy.path = EnemyAI.calculatePath(enemy, playerPosition)
        enemy.lastPathCalculation = tick()
        enemy.currentPathIndex = 1
    end

    -- Seguir path
    if enemy.path and enemy.currentPathIndex <= #enemy.path then
        local nextPoint = enemy.path[enemy.currentPathIndex].Position
        EnemyAI.moveTo(enemy, nextPoint, dt)

        if Utility.distance(enemy.position, nextPoint) < 1 then
            enemy.currentPathIndex = enemy.currentPathIndex + 1
        end
    else
        -- Ir directo si no hay path
        EnemyAI.moveTo(enemy, playerPosition, dt)
    end

    -- Verificar si puede atacar
    if dist <= 3 then
        enemy.state = AI_STATE.ATTACK
        Utility.log("EnemyAI", enemy.type .. " entró en estado ATTACK")
    end

    -- Perder al jugador
    if dist > enemy.detectionRange * 1.5 then
        enemy.state = AI_STATE.RETURN
    end
end

-- Estado ATTACK
function EnemyAI.updateAttack(enemy, dt, playerPosition)
    if not playerPosition then
        enemy.state = AI_STATE.CHASE
        return
    end

    local dist = Utility.distance(enemy.position, playerPosition)

    -- Mantenerse cerca
    if dist > 3 then
        enemy.state = AI_STATE.CHASE
        return
    end

    -- Atacar
    if tick() - enemy.lastAttackTime > CONFIG.ATTACK_COOLDOWN then
        enemy.lastAttackTime = tick()

        -- Notificar server para aplicar daño
        local CombatEvent = ReplicatedStorage:FindFirstChild("CombatEvent")
        if CombatEvent then
            CombatEvent:FireServer("enemyAttack", enemy, enemy.damage)
        end

        Utility.log("EnemyAI", enemy.type .. " atacó por " .. enemy.damage .. " daño")
    end
end

-- Estado RETURN
function EnemyAI.updateReturn(enemy, dt)
    local distToHome = Utility.distance(enemy.position, enemy.homePosition)

    if distToHome < 2 then
        enemy.state = AI_STATE.IDLE
        return
    end

    EnemyAI.moveTo(enemy, enemy.homePosition, dt)
end

-- Mover enemigo hacia posición
function EnemyAI.moveTo(enemy, targetPos, dt)
    local direction = (targetPos - enemy.position).Unit
    enemy.position = enemy.position + direction * enemy.speed * dt

    -- Rotar hacia la dirección
    if direction.Magnitude > 0.1 then
        enemy.rotation = CFrame.lookAt(enemy.position, enemy.position + direction)
    end
end

-- Calcular path (PathfindingService)
function EnemyAI.calculatePath(enemy, targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 6,
        AgentCanJump = true,
    })

    local success, result = pcall(function()
        return path:ComputeAsync(enemy.position, targetPos)
    end)

    if success and result == Enum.PathStatus.Success then
        return path:GetWaypoints()
    end

    return nil
end

-- Recibir daño
function EnemyAI.takeDamage(enemy, damage, hitZone, attacker)
    -- Multiplicador por zona
    local zoneMultipliers = {
        head = 2.5,
        torso = 1.5,
        limbs = 1.0,
    }

    local multiplier = zoneMultipliers[hitZone] or 1.0

    -- Verificar puntos débiles (Blindado)
    if enemy.type == "Blindado" and enemy.properties.armorPoints then
        if not table.find(enemy.properties.armorPoints, hitZone) then
            multiplier = multiplier * 1.5  -- Daño extra en puntos débiles
        end
    end

    local finalDamage = damage * multiplier
    enemy.health = enemy.health - finalDamage

    Utility.log("EnemyAI", enemy.type .. " recibió " .. finalDamage .. " daño (" .. enemy.health .. " HP)")

    -- Reaccionar al daño
    if enemy.state == AI_STATE.IDLE then
        enemy.state = AI_STATE.ALERT
        enemy.targetPlayer = attacker
    end

    -- Verificar muerte
    if enemy.health <= 0 then
        return true  -- Murió
    end

    return false  -- Sobrevivió
end

-- Obtener estado del enemigo
function EnemyAI.getStatus(enemy)
    return {
        type = enemy.type,
        state = enemy.state,
        health = enemy.health,
        position = enemy.position,
        target = enemy.targetPlayer,
    }
end

-- Limpiar enemigo
function EnemyAI.cleanup(enemy)
    enemy.path = nil
    enemy.targetPosition = nil
    enemy.targetPlayer = nil
end

return EnemyAI
