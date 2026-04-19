--[[
    AudioManager
    Control de música y efectos de sonido
    Sistema de audio 3D posicional
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Utility = require(ReplicatedStorage.Modules.Utility)

local AudioManager = {}

-- Configuración
local CONFIG = {
    MUSIC_VOLUME = 0.5,
    SFX_VOLUME = 0.5,
    VOICE_VOLUME = 0.5,
    MAX_AUDIO_SOURCES = 32,
    SILENCE_BEFORE_JUMPSCARE = 2.5,  -- segundos
    SILENCE_AFTER_INTENSE = 5,        -- segundos
}

-- Estado
local currentMusic = nil
local activeSounds = {}
local audioSources = {}
local isMuted = false
local isPaused = false

-- Referencias
local SoundService = game:GetService("SoundService")
local MusicFolder, SFXFolder, VoiceFolder

-- Inicializar
function AudioManager.init()
    -- Esperar carpetas
    MusicFolder = SoundService:FindFirstChild("Music")
    SFXFolder = SoundService:FindFirstChild("SFX")
    VoiceFolder = SoundService:FindFirstChild("Voice")

    if not MusicFolder then
        MusicFolder = Instance.new("Folder")
        MusicFolder.Name = "Music"
        MusicFolder.Parent = SoundService
    end

    if not SFXFolder then
        SFXFolder = Instance.new("Folder")
        SFXFolder.Name = "SFX"
        SFXFolder.Parent = SoundService
    end

    if not VoiceFolder then
        VoiceFolder = Instance.new("Folder")
        VoiceFolder.Name = "Voice"
        VoiceFolder.Parent = SoundService
    end

    -- Conectar eventos
    Utility.connect(game:GetService("RunService").Heartbeat, function(dt)
        AudioManager.update(dt)
    end)

    Utility.log("AudioManager", "Inicializado")
end

-- Reproducir música (reemplaza la anterior)
function AudioManager.playMusic(soundId, options)
    options = options or {}
    local volume = options.volume or CONFIG.MUSIC_VOLUME
    local fade = options.fade ~= false
    local loop = options.loop ~= false

    -- Detener música anterior
    if currentMusic then
        if fade then
            AudioManager.fadeOut(currentMusic, 1)
        else
            currentMusic:Stop()
        end
    end

    -- Crear nuevo sonido
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Looped = loop
    sound.Parent = MusicFolder

    -- Reproducir
    if fade then
        sound.Volume = 0
        sound:Play()
        AudioManager.fadeIn(sound, 2, volume)
    else
        sound:Play()
    end

    currentMusic = sound
    Utility.log("AudioManager", "Música iniciada: " .. soundId)

    return sound
end

-- Detener música
function AudioManager.stopMusic(fade)
    if currentMusic then
        if fade ~= false then
            AudioManager.fadeOut(currentMusic, 1)
        else
            currentMusic:Stop()
        end
        currentMusic = nil
    end
end

-- Pausar música
function AudioManager.pauseMusic()
    if currentMusic then
        currentMusic.Playing = false
        isPaused = true
    end
end

-- Reanudar música
function AudioManager.resumeMusic()
    if currentMusic and isPaused then
        currentMusic.Playing = true
        isPaused = false
    end
end

-- Reproducir SFX
function AudioManager.playSFX(soundId, options)
    options = options or {}
    local volume = options.volume or CONFIG.SFX_VOLUME
    local position = options.position  -- Vector3 para audio 3D
    local maxDistance = options.maxDistance or 100
    local rollOff = options.rollOff or Enum.DistanceAttenuation.Inverse

    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = SFXFolder

    -- Audio 3D si hay posición
    if position then
        local attachment = Instance.new("Attachment")
        attachment.WorldPosition = position
        attachment.Parent = workspace

        sound.Attachment = attachment
        sound.RollOffMode = rollOff
        sound.RollOffMinDistance = 5
        sound.RollOffMaxDistance = maxDistance

        -- Limpiar attachment después
        sound.Ended:Connect(function()
            attachment:Destroy()
        end)
    end

    -- Reproducir
    sound:Play()

    -- Limpieza automática
    sound.Ended:Connect(function()
        sound:Destroy()
    end)

    table.insert(activeSounds, sound)

    -- Limitar fuentes activas
    if #activeSounds > CONFIG.MAX_AUDIO_SOURCES then
        local oldest = table.remove(activeSounds, 1)
        if oldest and oldest.Playing then
            oldest:Stop()
        end
        oldest:Destroy()
    end

    return sound
end

-- Reproducir voz (monólogos de Eddie)
function AudioManager.playVoice(soundId, options)
    options = options or {}
    local volume = options.volume or CONFIG.VOICE_VOLUME
    local subtitle = options.subtitle

    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = VoiceFolder

    -- Mostrar subtítulo si existe
    if subtitle then
        -- Trigger UI de subtítulos
        local VoiceEvent = ReplicatedStorage:FindFirstChild("VoiceEvent")
        if VoiceEvent then
            VoiceEvent:FireClient("showSubtitle", subtitle)
        end
    end

    sound:Play()

    sound.Ended:Connect(function()
        sound:Destroy()
        if subtitle then
            local VoiceEvent = ReplicatedStorage:FindFirstChild("VoiceEvent")
            if VoiceEvent then
                VoiceEvent:FireClient("hideSubtitle")
            end
        end
    end)

    return sound
end

-- Fade in
function AudioManager.fadeIn(sound, duration, targetVolume)
    targetVolume = targetVolume or sound.Volume

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(sound, tweenInfo, {Volume = targetVolume})
    tween:Play()
end

-- Fade out
function AudioManager.fadeOut(sound, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(sound, tweenInfo, {Volume = 0})
    tween:Play()

    tween.Completed:Connect(function()
        sound:Stop()
        sound:Destroy()
    end)
end

-- Crear silencio (para tensión)
function AudioManager.createSilence(duration)
    duration = duration or 2

    -- Bajar todo el volumen gradualmente
    local originalMusicVolume = CONFIG.MUSIC_VOLUME
    local originalSFXVolume = CONFIG.SFX_VOLUME

    CONFIG.MUSIC_VOLUME = 0
    CONFIG.SFX_VOLUME = 0

    if currentMusic then
        AudioManager.fadeOut(currentMusic, 1)
    end

    -- Restaurar después del silencio
    task.delay(duration, function()
        CONFIG.MUSIC_VOLUME = originalMusicVolume
        CONFIG.SFX_VOLUME = originalSFXVolume
    end)
end

-- Actualizar volúmenes
function AudioManager.setVolumes(music, sfx, voice)
    if music then CONFIG.MUSIC_VOLUME = music end
    if sfx then CONFIG.SFX_VOLUME = sfx end
    if voice then CONFIG.VOICE_VOLUME = voice end

    if currentMusic then
        currentMusic.Volume = CONFIG.MUSIC_VOLUME
    end
end

-- Mute/Unmute
function AudioManager.toggleMute()
    isMuted = not isMuted

    if isMuted then
        if currentMusic then currentMusic.Volume = 0 end
    else
        if currentMusic then currentMusic.Volume = CONFIG.MUSIC_VOLUME end
    end

    return isMuted
end

-- Update loop
function AudioManager.update(dt)
    -- Limpiar sonidos finalizados
    for i = #activeSounds, 1, -1 do
        local sound = activeSounds[i]
        if not sound.Playing then
            table.remove(activeSounds, i)
        end
    end
end

-- Obtener estado
function AudioManager.getStatus()
    return {
        musicPlaying = currentMusic ~= nil and currentMusic.Playing,
        activeSounds = #activeSounds,
        isMuted = isMuted,
        isPaused = isPaused,
        volumes = {
            music = CONFIG.MUSIC_VOLUME,
            sfx = CONFIG.SFX_VOLUME,
            voice = CONFIG.VOICE_VOLUME,
        }
    }
end

return AudioManager
