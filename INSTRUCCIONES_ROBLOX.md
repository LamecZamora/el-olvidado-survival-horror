# 🎮 Instrucciones para Roblox Studio

## Problema: "No se ve nada en Roblox Studio"

Rojo sincroniza archivos, pero **necesitas tener un lugar (place) abierto** en Roblox Studio.

## ✅ Método 1: Usando Rojo (Recomendado)

### Paso 1: Abrir Roblox Studio
1. Abre **Roblox Studio**
2. Crea un **nuevo juego** (cualquier plantilla, ej: Baseplate)
3. **No cierres la ventana de Roblox Studio**

### Paso 2: Iniciar Rojo
```bash
cd C:\Users\cemal\Documents\visual\historia
rojo serve
```

Deberías ver:
```
[Rojo] Starting Rojo server...
[Rojo] Running on http://localhost:34872/
```

### Paso 3: Conectar Plugin
1. En Roblox Studio, ve a **Plugins** tab
2. Busca **Rojo** en la barra de herramientas
3. Click en **Rojo** → **Connect**
4. En la ventana que aparece, pon: `http://localhost:34872`
5. Click en **Connect**

### Paso 4: Verificar
- Abre **Explorer** (View → Explorer)
- Deberías ver las carpetas sincronizándose

---

## ✅ Método 2: Manual (Sin Rojo)

Si Rojo no funciona, puedes copiar manualmente:

### Paso 1: Ejecutar Script de Setup
1. En Roblox Studio, abre **View → Script Editor**
2. Copia el contenido de `setup_roblox.lua`
3. Pégalo en el editor y presiona **Play**

### Paso 2: Copiar Scripts Manualmente

**ReplicatedStorage → Modules:**
- `src/ReplicatedStorage/Modules/HealthManager.lua`
- `src/ReplicatedStorage/Modules/Utility.lua`
- `src/ReplicatedStorage/Modules/AudioManager.lua`
- `src/ReplicatedStorage/Modules/SaveManager.lua`
- `src/ReplicatedStorage/Modules/WeaponManager.lua`
- `src/ReplicatedStorage/Modules/InventoryManager.lua`
- `src/ReplicatedStorage/Modules/ProgressionManager.lua`
- `src/ReplicatedStorage/Modules/QuestManager.lua`
- `src/ReplicatedStorage/Modules/EnemyAI.lua`
- `src/ReplicatedStorage/Modules/MoralityManager.lua`

**ReplicatedStorage → Remotes:**
- `src/ReplicatedStorage/Remotes/Remotes.lua`

**ServerScriptService → Servers:**
- `src/ServerScriptService/Servers/MainServer.lua`
- `src/ServerScriptService/Servers/RemoteHandler.lua`
- `src/ServerScriptService/Servers/EnemySpawner.lua`
- `src/ServerScriptService/Servers/BossSpawner.lua`

**StarterPlayer → StarterPlayerScripts:**
- `src/StarterPlayer/StarterPlayerScripts/MainClient.lua`
- `src/StarterPlayer/StarterPlayerScripts/StarterGui.lua`

**Workspace → Zones:**
- `src/Workspace/Zones/ZoneStructure.lua`

**Lighting:**
- `src/Lighting/LightingSettings.lua`

### Paso 3: Configurar Tipo de Script
- **ModuleScript**: Todo lo que está en `Modules/`
- **Script** (Servidor): Todo lo que está en `Servers/`
- **LocalScript** (Cliente): Todo lo que está en `StarterPlayerScripts/`

---

## 🔧 Problemas Comunes

### "Rojo no conecta"
```bash
# Verificar que Rojo esté corriendo
rojo --version

# Matar proceso y reiniciar
# Ctrl+C en la terminal donde corre rojo
rojo serve
```

### "Scripts dan errores"
1. Asegúrate que los ModuleScript sean **ModuleScript** (no Script)
2. Los scripts del cliente deben ser **LocalScript**
3. Los scripts del servidor deben ser **Script**

### "UI no aparece"
- La UI está en `StarterPlayerScripts/StarterGui.lua`
- Debe ser un **LocalScript**
- Se ejecuta automáticamente al spawnear

---

## 🎯 Verificación Rápida

En la consola de Roblox Studio (View → Output), deberías ver:

```
[MainServer] Iniciando servidor...
[MainClient] Iniciando cliente...
[Remotes] Todos los remotes creados exitosamente
[StarterGui] UI creada exitosamente
```

---

## 📁 Estructura Final en Roblox Studio

```
ReplicatedStorage
  ├── Modules (Folder)
  │   └── [ModuleScripts]
  ├── Remotes (Folder)
  │   └── Remotes (ModuleScript)
  └── Assets (Folder)

ServerScriptService
  └── Servers (Folder)
      ├── MainServer (Script)
      └── RemoteHandler (Script)

StarterPlayer
  └── StarterPlayerScripts (Folder)
      ├── MainClient (LocalScript)
      └── StarterGui (LocalScript)

Workspace
  ├── Zones (Folder)
  │   └── ZoneStructure (Script)
  └── DefaultSpawn (SpawnLocation)

Lighting
  └── [Configurado automáticamente]
```
