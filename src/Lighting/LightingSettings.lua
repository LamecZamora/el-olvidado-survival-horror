--[[
    LightingSettings
    Configuración de iluminación para atmósfera de horror
--]]

local Lighting = game:GetService("Lighting")

-- Configuración de atmósfera
local Atmosphere = Instance.new("Atmosphere")
Atmosphere.Density = 0.5
Atmosphere.Offset = 3
Atmosphere.Color = Color3.fromRGB(30, 30, 40)
Atmosphere.Glare = 0.3
Atmosphere.Haze = 2
Atmosphere.Parent = Lighting

-- Configuración de tecnología
Lighting.Technology = Enum.Technology.Voxel
Lighting.Brightness = 1
Lighting.ClockTime = 0  -- Noche perpetua
Lighting.GeographicLatitude = 45
Lighting.EnvironmentSpecularScale = 0
Lighting.EnvironmentDiffuseScale = 0

-- Colores de ambiente (oscuros)
Lighting.Ambient = Color3.fromRGB(20, 20, 30)
Lighting.Brightness = 0.5
Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)

-- Sombra y niebla
Lighting.FogStart = 50
Lighting.FogEnd = 300
Lighting.FogColor = Color3.fromRGB(15, 15, 20)
