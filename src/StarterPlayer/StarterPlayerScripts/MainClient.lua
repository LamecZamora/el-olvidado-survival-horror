--[[
    MainClient
    Script principal del cliente - Loop y coordinación local
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Cargar módulos
local Utility = require(ReplicatedStorage.Modules.Utility)
local AudioManager = require(ReplicatedStorage.Modules.AudioManager)

-- Configuración
local CONFIG = {
    FOV_BASE = 70,
    FOV_ADS = 50,
    CAMERA_SMOOTHING = 0.15,
    MAX_TILT = 5,
}

-- Estado local
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Client = {
    isAiming = false,
    isSprinting = false,
    isCrouching = false,
    currentWeapon = nil,
    health = 100,
    stamina = 100,
}

-- Referencias
local camera = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- Inicializar cliente
function Client.init()
    Utility.log("MainClient", "Inicializando cliente...")

    -- Inicializar sistemas
    AudioManager.init()

    -- Configurar eventos de input
    Client.setupInputs()

    -- Configurar eventos de personaje
    Client.setupCharacterEvents()

    -- Iniciar loop principal
    Client.isRunning = true
    Client.lastUpdate = tick()

    -- Loop de renderizado (cada frame)
    RunService.RenderStepped:Connect(function(dt)
        Client.renderUpdate(dt)
    end)

    -- Loop de lógica (30 TPS)
    task.spawn(function()
        while Client.isRunning do
            Client.update()
            task.wait(1/30)
        end
    end)

    Utility.log("MainClient", "Cliente iniciado correctamente")
end

-- Configurar inputs
function Client.setupInputs()
    -- Teclado
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.Q then
            Client.toggleAim()
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            Client.toggleSprint()
        elseif input.KeyCode == Enum.KeyCode.C then
            Client.toggleCrouch()
        elseif input.KeyCode == Enum.KeyCode.F then
            Client.toggleFlashlight()
        elseif input.KeyCode == Enum.KeyCode.R then
            Client.reload()
        elseif input.KeyCode == Enum.KeyCode.I then
            Client.toggleInventory()
        elseif input.KeyCode == Enum.KeyCode.M then
            Client.toggleMute()
        end
    end)

    -- Mouse
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Client.fireWeapon()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            Client.toggleAim(true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Client.toggleAim(false)
        end
    end)
end

-- Configurar eventos de personaje
function Client.setupCharacterEvents()
    -- Cuando el personaje cambia (respawn)
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")

        Utility.log("MainClient", "Personaje renovado")
    end)

    -- Cambios de salud
    Humanoid.HealthChanged:Connect(function(health)
        Client.health = health
        Client.onHealthChanged(health)
    end)
end

-- Toggle aim (apuntar)
function Client.toggleAim(forceState)
    if forceState ~= nil then
        Client.isAiming = forceState
    else
        Client.isAiming = not Client.isAiming
    end

    -- Notificar UI
    local UIEvent = ReplicatedStorage:FindFirstChild("UIEvent")
    if UIEvent then
        UIEvent:FireServer("onAimChanged", Client.isAiming)
    end

    -- Ajustar FOV
    local targetFOV = Client.isAiming and CONFIG.FOV_ADS or CONFIG.FOV_BASE
    camera.FieldOfView = targetFOV
end

-- Toggle sprint
function Client.toggleSprint()
    Client.isSprinting = not Client.isSprinting

    -- Notificar server
    local MovementEvent = ReplicatedStorage:FindFirstChild("MovementEvent")
    if MovementEvent then
        MovementEvent:FireServer("setSprinting", Client.isSprinting)
    end
end

-- Toggle crouch
function Client.toggleCrouch()
    Client.isCrouching = not Client.isCrouching

    -- Notificar server
    local MovementEvent = ReplicatedStorage:FindFirstChild("MovementEvent")
    if MovementEvent then
        MovementEvent:FireServer("setCrouching", Client.isCrouching)
    end
end

-- Toggle flashlight
function Client.toggleFlashlight()
    local flashlight = Character:FindFirstChild("Flashlight")
    if flashlight then
        flashlight.Enabled = not flashlight.Enabled
    else
        -- Crear linterna si no existe
        Client.createFlashlight()
    end
end

-- Crear linterna
function Client.createFlashlight()
    local flashlight = Instance.new("SpotLight")
    flashlight.Name = "Flashlight"
    flashlight.Brightness = 2
    flashlight.Angle = 45
    flashlight.Parent = Character

    -- Posicionar en la cabeza
    local head = Character:FindFirstChild("Head")
    if head then
        flashlight.Parent = head
    end
end

-- Recargar
function Client.reload()
    if Client.currentWeapon then
        local WeaponEvent = ReplicatedStorage:FindFirstChild("WeaponEvent")
        if WeaponEvent then
            WeaponEvent:FireServer("reload", Client.currentWeapon)
        end
    end
end

-- Disparar
function Client.fireWeapon()
    if not Client.currentWeapon then return end
    if Client.isAiming then return end  -- Click derecho es para aim

    local WeaponEvent = ReplicatedStorage:FindFirstChild("WeaponEvent")
    if WeaponEvent then
        local hitPos = nil
        if mouse.Target then
            hitPos = mouse.Target.Position
        end
        WeaponEvent:FireServer("fire", Client.currentWeapon, hitPos)
    end
end

-- Toggle inventario
function Client.toggleInventory()
    local UIEvent = ReplicatedStorage:FindFirstChild("UIEvent")
    if UIEvent then
        UIEvent:FireServer("toggleInventory")
    end
end

-- Toggle mute
function Client.toggleMute()
    local muted = AudioManager.toggleMute()
    Utility.log("MainClient", "Audio mute: " .. tostring(muted))
end

-- Cuando la salud cambia
function Client.onHealthChanged(health)
    -- Efectos visuales de daño
    if health < 30 then
        -- Pantalla roja en baja salud
        local gui = LocalPlayer:FindFirstChild("HealthUI")
        if gui then
            -- Trigger efecto de sangre
        end
    end
end

-- Update loop (30 TPS)
function Client.update()
    -- Actualizar stamina
    Client.updateStamina()

    -- Enviar posición al server
    Client.sendPositionUpdate()
end

-- Update de stamina
function Client.updateStamina()
    local regenRate = 5  -- Por segundo
    local drainRate = 10

    if Client.isSprinting and Humanoid.MoveDirection.Magnitude > 0 then
        Client.stamina = math.max(0, Client.stamina - drainRate * (1/30))
    else
        Client.stamina = math.min(100, Client.stamina + regenRate * (1/30))
    end

    -- Notificar UI
    local StaminaEvent = ReplicatedStorage:FindFirstChild("StaminaEvent")
    if StaminaEvent then
        StaminaEvent:FireClient("updateStamina", Client.stamina)
    end
end

-- Enviar actualización de posición
function Client.sendPositionUpdate()
    local PositionEvent = ReplicatedStorage:FindFirstChild("PositionEvent")
    if PositionEvent and HumanoidRootPart then
        PositionEvent:FireServer(
            HumanoidRootPart.Position,
            HumanoidRootPart.Velocity,
            Client.isSprinting,
            Client.isCrouching
        )
    end
end

-- Render update (cada frame)
function Client.renderUpdate(dt)
    -- Actualizar cámara
    Client.updateCamera(dt)

    -- Actualizar crosshair
    Client.updateCrosshair(dt)
end

-- Actualizar cámara
function Client.updateCamera(dt)
    if not HumanoidRootPart then return end

    -- Cámara en tercera persona
    local targetPosition = HumanoidRootPart.Position + Vector3.new(0, 3, 0)
    local cameraOffset = Vector3.new(0, 2, -5)

    -- Ajustar offset si está apuntando
    if Client.isAiming then
        cameraOffset = Vector3.new(0, 1.5, -2)
    end

    -- Ajustar offset si está agachado
    if Client.isCrouching then
        cameraOffset = cameraOffset - Vector3.new(0, 1, 0)
    end

    local desiredPosition = targetPosition + cameraOffset
    camera.CFrame = CFrame.lookAt(desiredPosition, targetPosition)
end

-- Actualizar crosshair
function Client.updateCrosshair(dt)
    local CrosshairEvent = ReplicatedStorage:FindFirstChild("CrosshairEvent")
    if CrosshairEvent then
        -- Calcular dispersión basada en movimiento y estado
        local spread = 0

        if Humanoid.MoveDirection.Magnitude > 0 then
            spread = spread + 0.3
        end

        if Client.isSprinting then
            spread = spread + 0.4
        end

        if not Client.isAiming then
            spread = spread + 0.2
        end

        CrosshairEvent:FireClient("updateSpread", spread)
    end
end

-- Obtener estado del cliente
function Client.getStatus()
    return {
        isAiming = Client.isAiming,
        isSprinting = Client.isSprinting,
        isCrouching = Client.isCrouching,
        health = Client.health,
        stamina = Client.stamina,
        currentWeapon = Client.currentWeapon,
    }
end

-- Iniciar
task.spawn(function()
    task.wait(1)
    Client.init()
end)

return Client
