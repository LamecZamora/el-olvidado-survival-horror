# 🎮 Setup para Roblox Studio - El Olvidado

## ✅ Estado Actual

Tu proyecto ya está configurado con:

- ✅ Estructura de carpetas de Roblox
- ✅ Configuración de Rojo (`default.project.json`, `rojo.yml`)
- ✅ Sistema de Remotes para comunicación cliente-servidor
- ✅ HealthManager funcional
- ✅ MainClient y MainServer inicializados
- ✅ UI básica (Health, Stamina, Crosshair, Ammo)

## 🚀 Pasos para Empezar

### 1. Instalar Rojo (si no lo tienes)

```bash
# Windows - Usando Scoop
scoop install rojo

# O descarga desde: https://github.com/rojo-rbx/rojo/releases
```

### 2. Iniciar Rojo

```bash
cd C:\Users\cemal\Documents\visual\historia
rojo serve
```

### 3. Conectar Roblox Studio

1. Abre **Roblox Studio**
2. Crea un **nuevo juego Baseplate**
3. Ve a **Plugins → Rojo → Connect**
4. URL: `http://localhost:34872`
5. Click en **Connect**

### 4. Verificar Sincronización

En el Explorer de Roblox Studio deberías ver:
```
Workspace
  └── Zones (vacío por ahora)
ReplicatedStorage
  ├── Modules
  │   ├── HealthManager
  │   ├── Utility
  │   ├── AudioManager
  │   └── ...
  ├── Remotes
  │   └── Remotes
ServerScriptService
  └── Servers
      ├── MainServer
      └── RemoteHandler
StarterPlayer
  └── StarterPlayerScripts
      ├── MainClient
      └── StarterGui
Lighting
  └── LightingSettings
```

## 📁 Archivos Creados

```
src/
├── Lighting/
│   └── LightingSettings.lua       # Configuración de atmósfera
├── ReplicatedStorage/
│   ├── Remotes/
│   │   └── Remotes.lua            # Todos los RemoteEvents
│   └── Modules/                   # Módulos existentes
├── ServerScriptService/
│   └── Servers/
│       ├── MainServer.lua         # Server principal (actualizado)
│       └── RemoteHandler.lua      # Handler de remotes
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── MainClient.lua         # Cliente principal (actualizado)
        └── StarterGui.lua         # UI del juego
```

## 🎯 Siguiente: Crear la Zona 1

Para crear la primera zona del juego, necesitas:

1. **En Roblox Studio:**
   - Insertar un `Folder` llamado `Zones` en Workspace
   - Dentro, crear `Zone1` con:
     - `SpawnPoint` (SpawnLocation)
     - `ZoneTrigger` (Part con Trigger)

2. **O crear vía código:**
   ```lua
   -- En Workspace/Zones/ZoneStructure.lua
   ```

## 📋 Controles del Juego

| Tecla | Acción |
|-------|--------|
| W,A,S,D | Moverse |
| Shift | Sprint |
| C | Agacharse |
| Q | Apuntar |
| Click Izq | Disparar |
| Click Der | Apuntar (hold) |
| F | Linterna |
| R | Recargar |
| I | Inventario |
| M | Mute audio |

## 🔗 Documentos de Referencia

- `ROJO_SETUP.md` - Guía detallada de Rojo
- `README.md` - Documentación principal
- `docs/TECHNICAL_DESIGN.md` - Diseño técnico

## ⚠️ Importante

Los scripts actuales son **módulos de servidor/cliente**. Para que funcionen:

1. `MainServer.lua` debe estar en `ServerScriptService`
2. `MainClient.lua` debe estar en `StarterPlayerScripts`
3. Los módulos en `ReplicatedStorage.Modules` deben ser `ModuleScript`

Rojo se encarga de esto automáticamente si la configuración es correcta.
