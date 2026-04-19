--[[
    Utility Module
    Funciones helper compartidas para todo el juego
--]]

local Utility = {}

-- Imprimir con prefijo del sistema
function Utility.log(system, message)
    print(string.format("[%s] %s", system, message))
end

-- Imprimir error con stack trace
function Utility.error(system, message)
    error(string.format("[%s] %s\n%s", system, message, debug.traceback()))
end

-- Imprimir warning
function Utility.warn(system, message)
    warn(string.format("[%s] %s", system, message))
end

-- Clamp value entre min y max
function Utility.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Linear interpolation
function Utility.lerp(a, b, t)
    return a + (b - a) * Utility.clamp(t, 0, 1)
end

-- Calcular distancia entre dos puntos
function Utility.distance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Calcular distancia horizontal (ignora Y)
function Utility.horizontalDistance(pos1, pos2)
    local p1 = Vector3.new(pos1.X, 0, pos1.Z)
    local p2 = Vector3.new(pos2.X, 0, pos2.Z)
    return (p1 - p2).Magnitude
end

-- Verificar si un punto está en un radio
function Utility.isInRadius(center, point, radius)
    return Utility.distance(center, point) <= radius
end

-- Obtener valor aleatorio entre dos números
function Utility.randomRange(min, max)
    return min + math.random() * (max - min)
end

-- Elegir elemento aleatorio de una tabla
function Utility.randomChoice(t)
    return t[math.random(1, #t)]
end

-- Shuffle de tabla (Fisher-Yates)
function Utility.shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- Retraso asincrónico (yielding)
function Utility.wait(seconds)
    task.wait(seconds)
end

-- Intentar ejecutar función con reintentos
function Utility.retry(fn, retries, delay)
    retries = retries or 3
    delay = delay or 1

    local lastError
    for i = 1, retries do
        local success, result = pcall(fn)
        if success then
            return true, result
        end
        lastError = result
        Utility.wait(delay)
    end

    return false, lastError
end

-- Conectar señal con cleanup
function Utility.connect(signal, callback)
    local connection = signal:Connect(callback)
    return connection
end

-- Crear tabla con valores por defecto
function Utility.defaults(t, defaults)
    local result = {}
    for k, v in pairs(defaults) do
        result[k] = v
    end
    for k, v in pairs(t) do
        result[k] = v
    end
    return result
end

-- Verificar si tabla está vacía
function Utility.isEmpty(t)
    return next(t) == nil
end

-- Obtener tamaño de tabla
function Utility.size(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Deep copy de tabla
function Utility.deepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = Utility.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Serializar tabla a string (simple)
function Utility.serialize(t)
    return game:GetService("HttpService"):JSONEncode(t)
end

-- Deserializar string a tabla
function Utility.deserialize(s)
    return game:GetService("HttpService"):JSONDecode(s)
end

-- Formatear tiempo (segundos -> MM:SS)
function Utility.formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

-- Formatear número con separadores
function Utility.formatNumber(num)
    return string.format("%,d", num)
end

-- Obtener color de rareza
function Utility.getRarityColor(rarity)
    local colors = {
        Common = Color3.fromRGB(255, 255, 255),
        Uncommon = Color3.fromRGB(100, 255, 100),
        Rare = Color3.fromRGB(100, 100, 255),
        Epic = Color3.fromRGB(170, 0, 255),
        Legendary = Color3.fromRGB(255, 200, 0),
    }
    return colors[rarity] or colors.Common
end

-- Lerp de Color3
function Utility.colorLerp(c1, c2, t)
    t = Utility.clamp(t, 0, 1)
    return Color3.new(
        Utility.lerp(c1.R, c2.R, t),
        Utility.lerp(c1.G, c2.G, t),
        Utility.lerp(c1.B, c2.B, t)
    )
end

-- Verificar línea de visión entre dos puntos
function Utility.hasLineOfView(pos1, pos2, ignoreList)
    ignoreList = ignoreList or {}
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(pos1, pos2 - pos1, params)
    return result == nil
end

-- Encontrar ancestro o nil
function Utility.findAncestor(instance, name)
    if not instance then return nil end
    return instance:FindFirstAncestor(name)
end

-- Esperar a que un hijo exista
function Utility.waitForChild(parent, name, timeout)
    local child = parent:WaitForChild(name, timeout)
    if not child and timeout then
        Utility.warn("Utility", string.format("Child '%s' not found in '%s'", name, parent.Name))
    end
    return child
end

return Utility
