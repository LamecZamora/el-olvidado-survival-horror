# 🚀 Quick Start - El Olvidado en Roblox Studio

## En 5 Minutos

### 1️⃣ Instalar Rojo
```bash
scoop install rojo
# O descarga desde: https://github.com/rojo-rbx/rojo/releases
```

### 2️⃣ Iniciar Rojo
```bash
cd C:\Users\cemal\Documents\visual\historia
rojo serve
```

### 3️⃣ Conectar Roblox Studio
1. Abre **Roblox Studio**
2. Crea un **nuevo Baseplate**
3. **Plugins → Rojo → Connect**
4. URL: `http://localhost:34872`
5. **Connect**

### 4️⃣ Presiona Play
- Deberías ver la UI (Health, Stamina, Crosshair)
- Los logs deberían aparecer en la consola

---

## 📁 Estructura del Proyecto

```
historia/
├── src/
│   ├── ReplicatedStorage/
│   │   ├── Modules/          # HealthManager, Utility, etc.
│   │   └── Remotes/          # Remotes.lua (todos los eventos)
│   ├── ServerScriptService/
│   │   └── Servers/          # MainServer, RemoteHandler
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/  # MainClient, StarterGui
│   ├── Workspace/
│   │   └── Zones/            # ZoneStructure.lua (6 zonas)
│   └── Lighting/
│       └── LightingSettings.lua
├── default.project.json      # Config principal de Rojo
├── rojo.yml                  # Config de desarrollo
├── ROJO_SETUP.md             # Guía detallada de Rojo
├── SETUP_ROBLOX.md           # Setup completo
└── QUICKSTART.md             # Este archivo
```

---

## 🎮 Controles

| Tecla | Acción |
|-------|--------|
| **WASD** | Moverse |
| **Shift** | Sprint |
| **C** | Agacharse |
| **Q** | Apuntar (toggle) |
| **Click Der** | Apuntar (hold) |
| **Click Izq** | Disparar |
| **F** | Linterna |
| **R** | Recargar |
| **I** | Inventario |
| **M** | Mute audio |

---

## 🛠️ Comandos Útiles

```bash
# Desarrollo (sincronización en tiempo real)
rojo serve

# Build para producción
rojo build -o "El Olvidado.rbxl"

# Verificar git
git status
git add .
git commit -m "descripcion"
```

---

## ⚠️ Solución de Problemas

### "Rojo no conecta"
- Verifica que `rojo serve` esté corriendo
- Puerto 34872 disponible
- Firewall no bloquea

### "UI no aparece"
- Revisa la consola de Roblox Studio (View → Output)
- Verifica que StarterGui.lua se sincronizó

### "Scripts dan error"
- Asegúrate que los ModuleScript estén en `ReplicatedStorage/Modules`
- Los ServerScripts en `ServerScriptService`
- Los LocalScripts en `StarterPlayerScripts`

---

## 📚 Documentación Completa

- `README.md` - Descripción general del juego
- `ROJO_SETUP.md` - Configuración detallada de Rojo
- `SETUP_ROBLOX.md` - Setup completo para Roblox Studio
- `docs/TECHNICAL_DESIGN.md` - Diseño técnico
- `DOCUMENTO_MAESTRO_NARRATIVA.md` - Biblia narrativa

---

## ✅ Checklist de Configuración

- [ ] Rojo instalado (`rojo --version`)
- [ ] `rojo serve` corriendo
- [ ] Plugin de Rojo instalado en Roblox Studio
- [ ] Conectado a `http://localhost:34872`
- [ ] UI visible en el juego
- [ ] Logs aparecen en Output

---

**¿Listo? ¡A crear horror! 🎃**
