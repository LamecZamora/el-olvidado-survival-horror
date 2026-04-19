--[[
    HealthManager
    Sistema de salud y curación
    Maneja daño, curas y efectos de estado
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)

local HealthManager = {}

-- Configuración
local CONFIG = {
    MAX_HEALTH = 100,
    BASE_REGEN = 0.5,  -- Por segundo
    REGEN_DELAY = 5,   -- Segundos sin daño para regenerar
    CRITICAL_HEALTH = 25,
}

-- Estado
local currentHealth = 100
local maxHealth = 100
local isRegenerating = false
local lastDamageTime = 0
local activeBuffs = {}

-- Inicializar
function HealthManager.init()
    currentHealth = 100
    maxHealth = 100
    isRegenerating = false
    lastDamageTime = 0
    activeBuffs = {}

    Utility.log("HealthManager", "Inicializado")
end

-- Recibir daño
function HealthManager.takeDamage(amount, damageType, source)
    amount = math.max(0, amount)

    -- Aplicar resistencias si hay buffs
    if activeBuffs.resistance then
        amount = amount * (1 - activeBuffs.resistance)
    end

    currentHealth = math.max(0, currentHealth - amount)
    lastDamageTime = tick()

    Utility.log("HealthManager", string.format(
        "Daño recibido: %.1f (%s) de %s | Salud: %.1f/%.1f",
        amount, damageType or "normal", source or "desconocido",
        currentHealth, maxHealth
    ))

    -- Notificar UI
    HealthManager.notifyUI("damageTaken", {
        amount = amount,
        type = damageType,
        source = source,
        health = currentHealth,
        percent = currentHealth / maxHealth,
    })

    -- Verificar estado crítico
    if currentHealth <= CONFIG.CRITICAL_HEALTH then
        HealthManager.notifyUI("criticalHealth", true)
    end

    -- Verificar muerte
    if currentHealth <= 0 then
        HealthManager.onDeath(source)
        return true  -- Murió
    end

    return false  -- Sobrevivió
end

-- Curar
function HealthManager.heal(amount, source)
    amount = math.max(0, amount)

    local oldHealth = currentHealth
    currentHealth = math.min(maxHealth, currentHealth + amount)

    local healed = currentHealth - oldHealth

    Utility.log("HealthManager", string.format(
        "Curado: %.1f (%s) | Salud: %.1f → %.1f",
        healed, source or "desconocido", oldHealth, currentHealth
    ))

    -- Notificar UI
    HealthManager.notifyUI("healed", {
        amount = healed,
        source = source,
        health = currentHealth,
        percent = currentHealth / maxHealth,
    })

    -- Quitar estado crítico si aplica
    if currentHealth > CONFIG.CRITICAL_HEALTH then
        HealthManager.notifyUI("criticalHealth", false)
    end

    return healed
end

-- Usar item de curación
function HealthManager.useItem(itemId)
    local items = {
        ["SueroHidratante"] = {heal = 25, time = 2},
        ["Botiquin"] = {heal = 75, time = 3},
        ["InfusionBotanica"] = {heal = 100, buff = "max_health", buffTime = 120},
        ["VendajeBasico"] = {heal = 10, time = 1},
        ["SangreNocthyr"] = {heal = 50, cure = true, time = 4},
    }

    local item = items[itemId]
    if not item then
        Utility.warn("HealthManager", "Item desconocido: " .. itemId)
        return false
    end

    -- Aplicar curación
    if item.heal then
        HealthManager.heal(item.heal, itemId)
    end

    -- Aplicar buff si existe
    if item.buff then
        HealthManager.applyBuff(item.buff, item.buffTime or 60)
    end

    -- Curar efectos negativos
    if item.cure then
        HealthManager.cureDebuffs()
    end

    return true
end

-- Aplicar buff
function HealthManager.applyBuff(buffName, duration)
    activeBuffs[buffName] = {
        startTime = tick(),
        duration = duration,
    }

    Utility.log("HealthManager", "Buff aplicado: " .. buffName .. " (" .. duration .. "s)")

    -- Notificar UI
    HealthManager.notifyUI("buffApplied", {
        name = buffName,
        duration = duration,
    })
end

-- Quitar buff
function HealthManager.removeBuff(buffName)
    activeBuffs[buffName] = nil
    Utility.log("HealthManager", "Buff removido: " .. buffName)
end

-- Curar debuffs
function HealthManager.cureDebuffs()
    local debuffs = {"poison", "bleed", "paralyzed", "infected"}
    for _, debuff in ipairs(debuffs) do
        if activeBuffs[debuff] then
            HealthManager.removeBuff(debuff)
            Utility.log("HealthManager", "Debuff curado: " .. debuff)
        end
    end
end

-- Aplicar debuff
function HealthManager.applyDebuff(debuffName, duration, effect)
    activeBuffs[debuffName] = {
        startTime = tick(),
        duration = duration,
        effect = effect,
    }

    Utility.log("HealthManager", string.format(
        "Debuff aplicado: %s (%.1fs) - %s",
        debuffName, duration, tostring(effect)
    ))
end

-- Actualizar (llamado cada frame)
function HealthManager.update(dt)
    local now = tick()

    -- Regeneración pasiva
    if currentHealth < maxHealth and currentHealth > 0 then
        if now - lastDamageTime > CONFIG.REGEN_DELAY then
            isRegenerating = true
            local regen = CONFIG.BASE_REGEN * dt

            -- Buff de regeneración
            if activeBuffs.regen then
                regen = regen * 2
            end

            currentHealth = math.min(maxHealth, currentHealth + regen)

            -- Notificar UI periódicamente
            HealthManager.notifyUI("healthRegen", currentHealth / maxHealth)
        else
            isRegenerating = false
        end
    end

    -- Actualizar buffs
    for buffName, buffData in pairs(activeBuffs) do
        local elapsed = now - buffData.startTime
        if elapsed >= buffData.duration then
            HealthManager.removeBuff(buffName)
        end
    end
end

-- Cuando el jugador muere
function HealthManager.onDeath(source)
    Utility.log("HealthManager", "Jugador murió por: " .. tostring(source))

    -- Notificar server
    local DeathEvent = ReplicatedStorage:FindFirstChild("DeathEvent")
    if DeathEvent then
        DeathEvent:FireServer("playerDeath", source)
    end

    -- Notificar UI
    HealthManager.notifyUI("playerDeath", {
        source = source,
        timestamp = os.time(),
    })
end

-- Establecer salud máxima (para buffs)
function HealthManager.setMaxHealth(amount)
    local oldMax = maxHealth
    maxHealth = amount

    -- Ajustar salud actual proporcionalmente
    local percent = currentHealth / oldMax
    currentHealth = maxHealth * percent

    Utility.log("HealthManager", string.format(
        "Salud máxima: %d → %d", oldMax, maxHealth
    ))

    HealthManager.notifyUI("maxHealthChanged", maxHealth)
end

-- Obtener salud actual
function HealthManager.getHealth()
    return currentHealth
end

-- Obtener porcentaje de salud
function HealthManager.getHealthPercent()
    return currentHealth / maxHealth
end

-- Obtener salud máxima
function HealthManager.getMaxHealth()
    return maxHealth
end

-- Verificar si está en estado crítico
function HealthManager.isCritical()
    return currentHealth <= CONFIG.CRITICAL_HEALTH
end

-- Verificar si está muerto
function HealthManager.isDead()
    return currentHealth <= 0
end

-- Notificar UI
function HealthManager.notifyUI(event, data)
    local HealthEvent = ReplicatedStorage:FindFirstChild("HealthEvent")
    if HealthEvent then
        HealthEvent:FireClient("update", event, data)
    end
end

-- Obtener estado completo
function HealthManager.getStatus()
    return {
        health = currentHealth,
        maxHealth = maxHealth,
        percent = currentHealth / maxHealth,
        isRegenerating = isRegenerating,
        isCritical = HealthManager.isCritical(),
        isDead = HealthManager.isDead(),
        buffs = Utility.deepCopy(activeBuffs),
    }
end

-- Reset para nueva partida
function HealthManager.reset()
    HealthManager.init()
    Utility.log("HealthManager", "Reset completado")
end

return HealthManager
