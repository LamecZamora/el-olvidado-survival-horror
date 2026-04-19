--[[
    StarterGui
    Interfaz de usuario principal - Health, Stamina, Crosshair
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Crear UI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ============================================
-- HEALTH BAR
-- ============================================
local HealthFrame = Instance.new("Frame")
HealthFrame.Name = "HealthFrame"
HealthFrame.Size = UDim2.new(0, 250, 0, 30)
HealthFrame.Position = UDim2.new(0, 20, 1, -80)
HealthFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HealthFrame.BorderSizePixel = 0
HealthFrame.Parent = ScreenGui

local HealthBar = Instance.new("Frame")
HealthBar.Name = "HealthBar"
HealthBar.Size = UDim2.new(0.96, 0, 0.8, 0)
HealthBar.Position = UDim2.new(0.02, 0, 0.1, 0)
HealthBar.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
HealthBar.BorderSizePixel = 0
HealthBar.Parent = HealthFrame

local HealthLabel = Instance.new("TextLabel")
HealthLabel.Name = "HealthLabel"
HealthLabel.Size = UDim2.new(1, 0, 1, 0)
HealthLabel.BackgroundTransparency = 1
HealthLabel.Text = "100 / 100"
HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthLabel.TextSize = 18
HealthLabel.Font = Enum.Font.GothamBold
HealthLabel.TextStrokeTransparency = 0
HealthLabel.Parent = HealthFrame

-- ============================================
-- STAMINA BAR
-- ============================================
local StaminaFrame = Instance.new("Frame")
StaminaFrame.Name = "StaminaFrame"
StaminaFrame.Size = UDim2.new(0, 250, 0, 15)
StaminaFrame.Position = UDim2.new(0, 20, 1, -45)
StaminaFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StaminaFrame.BorderSizePixel = 0
StaminaFrame.Parent = ScreenGui

local StaminaBar = Instance.new("Frame")
StaminaBar.Name = "StaminaBar"
StaminaBar.Size = UDim2.new(0.96, 0, 0.8, 0)
StaminaBar.Position = UDim2.new(0.02, 0, 0.1, 0)
StaminaBar.BackgroundColor3 = Color3.fromRGB(50, 180, 255)
StaminaBar.BorderSizePixel = 0
StaminaBar.Parent = StaminaFrame

-- ============================================
-- CROSSHAIR
-- ============================================
local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Name = "CrosshairFrame"
CrosshairFrame.Size = UDim2.new(0, 20, 0, 20)
CrosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Parent = ScreenGui

local CrosshairDot = Instance.new("Frame")
CrosshairDot.Name = "Dot"
CrosshairDot.Size = UDim2.new(0, 4, 0, 4)
CrosshairDot.Position = UDim2.new(0.5, -2, 0.5, -2)
CrosshairDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CrosshairDot.BorderSizePixel = 0
CrosshairDot.Parent = CrosshairFrame

local CrosshairCircle = Instance.new("Frame")
CrosshairCircle.Name = "Circle"
CrosshairCircle.Size = UDim2.new(0, 20, 0, 20)
CrosshairCircle.Position = UDim2.new(0.5, -10, 0.5, -10)
CrosshairCircle.BackgroundTransparency = 0.5
CrosshairCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CrosshairCircle.BorderSizePixel = 0
CrosshairCircle.Parent = CrosshairFrame

-- ============================================
-- AMMO DISPLAY
-- ============================================
local AmmoFrame = Instance.new("Frame")
AmmoFrame.Name = "AmmoFrame"
AmmoFrame.Size = UDim2.new(0, 120, 0, 50)
AmmoFrame.Position = UDim2.new(1, -140, 1, -80)
AmmoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AmmoFrame.BorderSizePixel = 0
AmmoFrame.Parent = ScreenGui

local AmmoLabel = Instance.new("TextLabel")
AmmoLabel.Name = "AmmoLabel"
AmmoLabel.Size = UDim2.new(1, 0, 1, 0)
AmmoLabel.BackgroundTransparency = 1
AmmoLabel.Text = "8 / 24"
AmmoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AmmoLabel.TextSize = 28
AmmoLabel.Font = Enum.Font.GothamBold
AmmoLabel.TextStrokeTransparency = 0
AmmoLabel.Parent = AmmoFrame

-- ============================================
-- ESCUELA (Mensaje de estado)
-- ============================================
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(0, 300, 0, 40)
StatusFrame.Position = UDim2.new(0.5, -150, 0, 60)
StatusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusFrame.BackgroundTransparency = 0.3
StatusFrame.BorderSizePixel = 0
StatusFrame.Visible = false
StatusFrame.Parent = ScreenGui

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 20
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextStrokeTransparency = 0
StatusLabel.Parent = StatusFrame

print("[StarterGui] UI creada exitosamente")
