# El Olvidado — Survival Horror

**Survival Horror para Roblox**

> "El horror no proviene del gore. Proviene de la vulnerabilidad humana."

---

## 📋 Descripción

"El Olvidado" es un juego de Survival Horror ambientado en la ciudad de Vael, devastada por un brote biológico de PharmaCorp. Los jugadores controlan a Eddie, un joven que busca a sus padres desaparecidos en el epicentro del brote: **Punto Cero**.

### Características Principales

- **6 Zonas** interconectadas (2.5-5 horas cada una)
- **5 Jefes** únicos con mecánicas de 2 fases
- **9 Misiones** secundarias de los Trolelotes
- **7 Finales** determinados por decisiones acumuladas
- **Sistema de moralidad oculto** que afecta el final
- **34 Grabaciones**, 20 fotos, 12 archivos, 8 partes del diario

---

## 🎮 Mecánicas

### Supervivencia
- Escasez constante de munición y recursos
- Cada bala cuenta
- Eddie mejora pero nunca es un soldado

### Combate
- 12 armas principales con modificadores
- Sistema de venenos (Nocthyr)
- Curación con 3 tipos de items

### Progresión
- 3 niveles ocultos de habilidad
- Sin barras de XP visibles
- Mejoras narrativas y visuales

### Comercio
- **Lince** — Armas y modificadores (Zona 2)
- **Nocthyr** — Venenos y curas (Zona 3)
- **Héroe del Chocomilk** — Misiones (Zona 5)

---

## 🏗️ Estructura del Proyecto

```
historia/
├── src/
│   ├── ReplicatedStorage/
│   │   ├── Modules/          # Módulos compartidos
│   │   ├── Assets/           # Configuraciones de armas, items, enemigos
│   │   └── Remotes/          # Eventos de red
│   ├── ServerScriptService/
│   │   ├── Servers/          # Scripts del servidor
│   │   └── Modules/          # Módulos del servidor
│   ├── StarterPlayer/
│   │   ├── StarterPlayerScripts/     # Scripts del cliente
│   │   └── StarterCharacterScripts/  # Scripts del personaje
│   └── Workspace/
│       ├── Zones/            # Las 6 zonas del juego
│       ├── Merchants/        # NPCs comerciantes
│       ├── Bosses/           # Jefes
│       └── Collectibles/     # Items coleccionables
├── assets/                   # Modelos, texturas, audio
├── docs/                     # Documentación
├── tests/                    # Tests automatizados
├── default.project.json      # Configuración de Rojo
└── README.md
```

---

## 🚀 Desarrollo

### Requisitos

- **Roblox Studio** (versión más reciente)
- **Rojo** (`rojo` CLI) para sincronización VS Code ↔ Roblox
- **Git** para control de versiones

### Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone <repo-url>
   cd historia
   ```

2. **Instalar dependencias:**
   ```bash
   # Si usas Wally para paquetes
   wally install
   ```

3. **Sincronizar con Roblox Studio:**
   ```bash
   rojo serve --address 0.0.0.0
   ```

4. **Conectar en Roblox Studio:**
   - Plugins → Rojo → Connect
   - Usar URL: `http://localhost:34872`

### Comandos Útiles

```bash
# Verificar estado
git status

# Ejecutar tests
rojo test tests/

# Build para producción
rojo build -o "El Olvidado.rbxl"
```

---

## 📖 Documentación

- **[DOCUMENTO_MAESTRO_NARRATIVA.md](docs/DOCUMENTO_MAESTRO_NARRATIVA.md)** — Biblia narrativa completa (22,000+ líneas)
- **TECHNICAL_DESIGN.md** — Documentación técnica (próximamente)
- **ART_BIBLE.md** — Guía de arte (próximamente)
- **AUDIO_BIBLE.md** — Guía de audio (próximamente)

---

## 🎯 Roadmap

### Fase 1: Pre-Producción (4 semanas)
- [x] Estructura del repositorio
- [x] Módulos base (Utility, MoralityManager, AudioManager)
- [x] Sistema de guardado (SaveManager)
- [x] WeaponManager completo
- [ ] Prototipo de Zona 1
- [ ] Sistema de combate básico

### Fase 2: Producción Temprana (8 semanas)
- [ ] Zona 1 completa
- [ ] Zona 2 completa
- [ ] Lince implementado
- [ ] Primer jefe (El Vigilante)

### Fase 3: Producción Principal (12 semanas)
- [ ] Zonas 3-4
- [ ] Zonas 5-6
- [ ] Todos los Trolelotes
- [ ] Todos los jefes
- [ ] Sistema de finales

### Fase 4: Beta y Lanzamiento (8 semanas)
- [ ] Beta cerrada
- [ ] Beta abierta
- [ ] Lanzamiento oficial

---

## 👥 Equipo

Este es un proyecto open-source. Todas las contribuciones son bienvenidas.

### Roles Necesarios
- Programadores Lua/Roblox
- Modeladores 3D
- Diseñadores de sonido
- Testers

---

## 📜 Licencia

MIT License — Ver [LICENSE](LICENSE) para detalles.

---

## ⚠️ Advertencia de Contenido

Este juego contiene:
- Terror psicológico
- Violencia (no gore gratuito)
- Temas maduros (pérdida, aislamiento)
- Jump scares ocasionales

**No es recomendado para menores de 16 años.**

---

## 🔗 Enlaces

- [Documento Narrativo Completo](docs/DOCUMENTO_MAESTRO_NARRATIVA.md)
- [Roblox Developer Forum](https://devforum.roblox.com/)
- [Documentación de Rojo](https://rojo.space/)

---

> *"Bien hecho. Eso fue solo el primer nivel."*
