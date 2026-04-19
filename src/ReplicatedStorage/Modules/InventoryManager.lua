--[[
    InventoryManager
    Sistema de inventario (20 slots)
    Manejo de armas, items y coleccionables
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local WeaponManager = require(ReplicatedStorage.Modules.WeaponManager)

local InventoryManager = {}

-- Configuración
local CONFIG = {
    MAX_SLOTS = 20,
    MAX_WEAPONS = 4,
    MAX_ITEMS = 10,
    MAX_AMMO = 5,
}

-- Estado local del inventario
local inventory = {
    weapons = {},      -- Lista de armas equipadas
    items = {},        -- Items consumibles
    ammo = {},         -- Tipos de munición
    collectibles = {   -- Coleccionables (no ocupan slots)
        recordings = {},
        photos = {},
        files = {},
        diary = {},
    },
    equippedWeapon = nil,
}

-- Inicializar
function InventoryManager.init()
    inventory = {
        weapons = {},
        items = {},
        ammo = {},
        collectibles = {
            recordings = {},
            photos = {},
            files = {},
            diary = {},
        },
        equippedWeapon = nil,
    }

    Utility.log("InventoryManager", "Inicializado")
end

-- Obtener slots libres
function InventoryManager.getFreeSlots()
    local usedSlots = #inventory.weapons + #inventory.items + #inventory.ammo
    return CONFIG.MAX_SLOTS - usedSlots
end

-- Verificar si hay espacio
function InventoryManager.hasSpace()
    return InventoryManager.getFreeSlots() > 0
end

-- Agregar arma
function InventoryManager.addWeapon(weaponId, ammo, mods)
    if #inventory.weapons >= CONFIG.MAX_WEAPONS then
        Utility.warn("InventoryManager", "Máximo de armas alcanzado")
        return false, "No puedes llevar más armas (máx 4)"
    end

    local weapon = WeaponManager.getWeapon(weaponId)
    if not weapon then
        return false, "Arma no encontrada"
    end

    table.insert(inventory.weapons, {
        id = weaponId,
        name = weapon.name,
        ammo = ammo or weapon.capacity,
        maxAmmo = weapon.capacity,
        mods = mods or {},
    })

    Utility.log("InventoryManager", "Arma agregada: " .. weapon.name)

    -- Notificar UI
    InventoryManager.notifyUI("weaponAdded", weaponId)

    return true, nil
end

-- Remover arma
function InventoryManager.removeWeapon(index)
    if index < 1 or index > #inventory.weapons then
        return false, "Índice inválido"
    end

    local weapon = table.remove(inventory.weapons, index)

    -- Si era la equipada, desequipar
    if inventory.equippedWeapon == index then
        inventory.equippedWeapon = nil
    end

    Utility.log("InventoryManager", "Arma removida: " .. weapon.name)
    InventoryManager.notifyUI("weaponRemoved", index)

    return true, nil
end

-- Agregar item
function InventoryManager.addItem(itemId, count)
    count = count or 1

    -- Verificar si ya existe (stackable)
    for _, item in ipairs(inventory.items) do
        if item.id == itemId then
            item.count = item.count + count
            Utility.log("InventoryManager", "Item stackeado: " .. itemId .. " x" .. item.count)
            InventoryManager.notifyUI("itemStacked", itemId)
            return true, nil
        end
    end

    -- Nuevo item
    if #inventory.items >= CONFIG.MAX_ITEMS then
        Utility.warn("InventoryManager", "Máximo de items alcanzado")
        return false, "No puedes llevar más items"
    end

    table.insert(inventory.items, {
        id = itemId,
        count = count,
    })

    Utility.log("InventoryManager", "Item agregado: " .. itemId .. " x" .. count)
    InventoryManager.notifyUI("itemAdded", itemId)

    return true, nil
end

-- Usar item
function InventoryManager.useItem(itemId)
    for i, item in ipairs(inventory.items) do
        if item.id == itemId then
            if item.count <= 0 then
                table.remove(inventory.items, i)
                return false, "Item agotado"
            end

            -- Aplicar efecto del item
            local success, effect = InventoryManager.applyItemEffect(itemId)
            if success then
                item.count = item.count - 1

                if item.count <= 0 then
                    table.remove(inventory.items, i)
                end

                Utility.log("InventoryManager", "Item usado: " .. itemId)
                InventoryManager.notifyUI("itemUsed", itemId)

                return true, effect
            else
                return false, effect
            end
        end
    end

    return false, "Item no encontrado"
end

-- Aplicar efecto de item
function InventoryManager.applyItemEffect(itemId)
    local effects = {
        ["SueroHidratante"] = {type = "heal", value = 25},
        ["Botiquin"] = {type = "heal", value = 75},
        ["InfusionBotanica"] = {type = "heal_max", value = 100, buff = true},
        ["VendajeBasico"] = {type = "heal", value = 10},
        ["SangreNocthyr"] = {type = "heal_cure", value = 50},
    }

    local effect = effects[itemId]
    if not effect then
        return false, "Efecto desconocido"
    end

    -- Notificar al server para aplicar efecto
    local HealthEvent = ReplicatedStorage:FindFirstChild("HealthEvent")
    if HealthEvent then
        HealthEvent:FireServer("useItem", itemId, effect)
    end

    return true, effect
end

-- Agregar munición
function InventoryManager.addAmmo(ammoType, count)
    count = count or 1

    if inventory.ammo[ammoType] then
        inventory.ammo[ammoType] = inventory.ammo[ammoType] + count
    else
        if #inventory.ammo >= CONFIG.MAX_AMMO then
            Utility.warn("InventoryManager", "Máximo de tipos de munición")
            return false
        end
        inventory.ammo[ammoType] = count
    end

    Utility.log("InventoryManager", "Munición agregada: " .. ammoType .. " x" .. count)
    InventoryManager.notifyUI("ammoAdded", ammoType)

    return true
end

-- Remover munición
function InventoryManager.removeAmmo(ammoType, count)
    if not inventory.ammo[ammoType] then
        return false
    end

    inventory.ammo[ammoType] = inventory.ammo[ammoType] - count

    if inventory.ammo[ammoType] <= 0 then
        inventory.ammo[ammoType] = nil
    end

    return true
end

-- Equipar arma
function InventoryManager.equipWeapon(index)
    if index < 1 or index > #inventory.weapons then
        return false, "Índice inválido"
    end

    inventory.equippedWeapon = index
    local weapon = inventory.weapons[index]

    Utility.log("InventoryManager", "Arma equipada: " .. weapon.name)
    InventoryManager.notifyUI("weaponEquipped", index)

    return true, weapon
end

-- Obtener arma equipada
function InventoryManager.getEquippedWeapon()
    if not inventory.equippedWeapon then
        return nil
    end

    return inventory.weapons[inventory.equippedWeapon]
end

-- Agregar coleccionable
function InventoryManager.addCollectible(type, id, data)
    if not inventory.collectibles[type] then
        Utility.warn("InventoryManager", "Tipo de coleccionable inválido: " .. type)
        return false
    end

    -- Verificar si ya existe
    for _, existing in ipairs(inventory.collectibles[type]) do
        if existing.id == id then
            return false, "Coleccionable ya obtenido"
        end
    end

    table.insert(inventory.collectibles[type], {
        id = id,
        data = data,
        obtainedAt = os.time(),
    })

    Utility.log("InventoryManager", "Coleccionable agregado: " .. type .. " #" .. id)

    -- Notificar para moralidad
    local MoralityEvent = ReplicatedStorage:FindFirstChild("MoralityEvent")
    if MoralityEvent then
        MoralityEvent:FireServer("addCollectible", type, id)
    end

    InventoryManager.notifyUI("collectibleAdded", type)

    return true
end

-- Verificar coleccionable obtenido
function InventoryManager.hasCollectible(type, id)
    if not inventory.collectibles[type] then
        return false
    end

    for _, item in ipairs(inventory.collectibles[type]) do
        if item.id == id then
            return true
        end
    end

    return false
end

-- Obtener progreso de coleccionables
function InventoryManager.getCollectibleProgress()
    local total = 0
    local obtained = 0

    local expected = {
        recordings = 34,
        photos = 20,
        files = 12,
        diary = 8,
    }

    for type, list in pairs(inventory.collectibles) do
        obtained = obtained + #list
        total = total + (expected[type] or 0)
    end

    return {
        total = total,
        obtained = obtained,
        recordings = #inventory.collectibles.recordings,
        photos = #inventory.collectibles.photos,
        files = #inventory.collectibles.files,
        diary = #inventory.collectibles.diary,
    }
end

-- Notificar UI de cambios
function InventoryManager.notifyUI(event, data)
    local InventoryEvent = ReplicatedStorage:FindFirstChild("InventoryEvent")
    if InventoryEvent then
        InventoryEvent:FireClient("update", event, data)
    end
end

-- Obtener inventario completo (para guardado)
function InventoryManager.getFullInventory()
    return Utility.deepCopy(inventory)
end

-- Cargar inventario desde guardado
function InventoryManager.loadInventory(data)
    if data then
        inventory = Utility.deepCopy(data)
        Utility.log("InventoryManager", "Inventario cargado")
    end
end

-- Contar items totales
function InventoryManager.getItemCount()
    return #inventory.weapons + #inventory.items + #inventory.ammo
end

-- Limpiar inventario
function InventoryManager.clear()
    inventory = {
        weapons = {},
        items = {},
        ammo = {},
        collectibles = {
            recordings = {},
            photos = {},
            files = {},
            diary = {},
        },
        equippedWeapon = nil,
    }
    Utility.log("InventoryManager", "Inventario limpiado")
end

return InventoryManager
