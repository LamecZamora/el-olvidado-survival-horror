# Configuración de Rojo - El Olvidado

## 📋 Requisitos

1. **Roblox Studio** instalado y actualizado
2. **Rojo CLI** instalado (`rojo` command)

## 🚀 Instalación de Rojo

### Windows

```bash
# Opción A: Usando Scoop (recomendado)
scoop install rojo

# Opción B: Descarga manual
# 1. Ve a https://github.com/rojo-rbx/rojo/releases
# 2. Descarga el .zip más reciente
# 3. Extrae a C:\rojo
# 4. Agrega C:\rojo a tu PATH
```

### Verificar instalación

```bash
rojo --version
```

## 🔌 Conectar con Roblox Studio

### Paso 1: Iniciar el servidor Rojo

```bash
# Desde la carpeta del proyecto
rojo serve
```

Verás algo como:
```
[Rojo] Starting Rojo server...
[Rojo] Running on http://localhost:34872/
```

### Paso 2: Conectar en Roblox Studio

1. Abre **Roblox Studio**
2. Ve a la pestaña **Plugins**
3. Busca **Rojo** en la lista de plugins
4. Si no lo tienes, instálalo desde: https://www.roblox.com/library/1530442836/Rojo-Connector
5. Click en **Rojo → Connect**
6. Usa la URL: `http://localhost:34872`
7. Click en **Connect**

### Paso 3: Verificar conexión

- Deberías ver los archivos sincronizarse en el Explorer de Roblox Studio
- Los archivos `.lua` se sincronizarán automáticamente

## 📁 Estructura Sincronizada

```
Roblox Studio          ←→  Tu Proyecto
─────────────────────────────────────────────
ReplicatedStorage       ←→  src/ReplicatedStorage
ServerScriptService     ←→  src/ServerScriptService
StarterPlayerScripts    ←→  src/StarterPlayer/StarterPlayerScripts
Workspace               ←→  src/Workspace
Lighting                ←→  src/Lighting
SoundService            ←→  src/SoundService
```

## 🎮 Comandos Útiles

```bash
# Iniciar servidor de desarrollo
rojo serve

# Build para producción (archivo .rbxl)
rojo build -o "El Olvidado.rbxl"

# Build solo de algunos archivos
rojo build --include src/ReplicatedStorage

# Verificar configuración
rojo project place default.project.json
```

## ⚠️ Problemas Comunes

### "No se pudo conectar"
- Asegúrate de que `rojo serve` esté corriendo
- Verifica que el puerto 34872 no esté bloqueado
- En Windows Firewall, permite Rojo

### "Archivo no se sincroniza"
- Verifica `.rojoignore` 
- Asegúrate que el archivo esté en la carpeta correcta
- Reinicia `rojo serve`

### "Plugin no aparece"
- Instala el plugin desde la Roblox Library
- Reinicia Roblox Studio
- Verifica Plugins → Rojo

## 🎯 Siguientes Pasos

1. ✅ Rojo configurado y conectado
2. ⏭️ Crear estructura del Workspace (Zonas)
3. ⏭️ Configurar UI (HealthBar, Stamina, Crosshair)
4. ⏭️ Implementar sistemas de juego

## 🔗 Recursos

- [Documentación Oficial de Rojo](https://rojo.space/)
- [GitHub de Rojo](https://github.com/rojo-rbx/rojo)
- [Foro de Desarrolladores Roblox](https://devforum.roblox.com/)
