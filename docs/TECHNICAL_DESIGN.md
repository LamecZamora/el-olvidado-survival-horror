# Technical Design Document
## El Olvidado - Survival Horror

**Versión:** 1.0  
**Fecha:** 18 de Abril, 2026  
**Estado:** En desarrollo

---

## 1. Arquitectura General

### 1.1 Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                         ROBLOX STUDIO                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐         ┌─────────────────┐               │
│  │   CLIENT SIDE   │         │   SERVER SIDE   │               │
│  │                 │         │                 │               │
│  │ MainClient.lua  │◄───────►│  MainServer.lua │               │
│  │                 │  Remote │                 │               │
│  │ CameraCtrl      │  Events │  EnemySpawner   │               │
│  │ InputHandler    │         │  BossSpawner    │               │
│  │ UIController    │         │  SaveServer     │               │
│  │                 │         │                 │               │
│  └─────────────────┘         └─────────────────┘               │
│           │                           │                         │
│           │    ┌─────────────────┐    │                         │
│           └───►│  REPLICATED     │◄───┘                         │
│                │    STORAGE      │                              │
│                │                 │                              │
│                │ Modules:        │                              │
│                │ - Utility       │                              │
│                │ - MoralityMgr   │                              │
│                │ - AudioManager  │                              │
│                │ - WeaponMgr     │                              │
│                │ - InventoryMgr  │                              │
│                │ - EnemyAI       │                              │
│                │ - QuestMgr      │                              │
│                │ - ProgressionMgr│                              │
│                │ - SaveManager   │                              │
│                └─────────────────┘                              │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Flujo de Datos

```
Jugador → Input → Client Script → RemoteEvent → Server Script → Game State
                                                              ↓
Jugador ◄── Render ◄── Client Script ◄── RemoteEvent ◄───┘
```

---

## 2. Módulos Principales

### 2.1 Utility.lua
Funciones helper compartidas.

| Función | Descripción |
|---------|-------------|
| `clamp()` | Limita valor entre min/max |
| `lerp()` | Interpolación lineal |
| `distance()` | Calcula distancia 3D |
| `randomChoice()` | Elemento aleatorio de tabla |
| `retry()` | Reintentar función con delay |

### 2.2 MoralityManager.lua
Sistema de moralidad oculto.

- **Puntaje base:** 50 (0-100 rango)
- **40+ acciones** con valores positivos/negativos
- **7 finales** determinados por umbrales
- **Flags especiales** para finales C, D, G

### 2.3 AudioManager.lua
Control de audio 3D.

- Música ambiental por zona
- SFX posicionales
- Voces de monólogos
- Sistema de silencio dinámico

### 2.4 WeaponManager.lua
12 armas configuradas.

| Categoría | Armas |
|-----------|-------|
| Pistolas | HG-18, D-19, MILTON-9, MG-ULTRA |
| Escopetas | THUNDER 12, VAR-P |
| Rifles | HUNTER-338, EAGLE EYE |
| Especiales | HEAVY 50, COIL-33X, BREAKER GUN |
| Melee | Cuchillo, Hacha, Palanca |

### 2.5 EnemyAI.lua
IA de infectados con 4 estados:

1. **IDLE** - Patrullar área
2. **ALERT** - Investigar sonido
3. **CHASE** - Perseguir jugador
4. **ATTACK** - Atacar

### 2.6 QuestManager.lua
9 misiones de Trolelotes.

| Trolelote | Misiones |
|-----------|----------|
| Lince | M1, M4, M7 |
| Nocthyr | M2, M5, M8 |
| Héroe del Chocomilk | M3, M6, M9 |

---

## 3. Servidor

### 3.1 MainServer.lua
Loop principal (30 TPS).

- Control de estado global
- Coordinación de sistemas
- Auto-guardado cada 5 minutos

### 3.2 EnemySpawner.lua
Spawn dinámico.

| Zona | Densidad | Tipos |
|------|----------|-------|
| Zone1 | 5 | Common |
| Zone2 | 15 | Common, Corredor |
| Zone3 | 20 | Common, Corredor, Blindado |
| Zone4 | 25 | + Acechador |
| Zone5 | 12 | Common, Corredor, Acechador |
| Zone6 | 18 | Todos |

### 3.3 BossSpawner.lua
5 jefes con 2 fases.

| Jefe | Zona | HP | Fases |
|------|------|-----|-------|
| El Vigilante | Zone2 | 500 | Silbato → Furia |
| El Encerrado | Zone3 | 800 | Cadenas → Rugido |
| La Doctora | Zone4 | 600 | Instrumentos → Sierras |
| La Manada | Zone5 | 900 | Cerco → Venganza |
| Comandante Reyes | Zone6 | 1000 | Táctica → Fanático |

### 3.4 SaveServer.lua
DataStore con backup.

- Guardado automático (5 min)
- Guardado manual (zonas seguras)
- Migración de versiones

---

## 4. Cliente

### 4.1 MainClient.lua
Loop de renderizado (60 FPS).

- Input handling
- Cámara tercera persona
- Control de stamina

### 4.2 CameraController.lua
- FOV dinámico (70 → 50 al apuntar)
- Camera sway según estado de Eddie
- Smooth follow

### 4.3 UIController.lua
Interfaces:

- Salud (barra + efectos)
- Munición (contador)
- Inventario (20 slots)
- Diálogos (cajas + opciones)
- Misiones (lista + progreso)

---

## 5. DataStore

### 5.1 Estructura de Guardado

```lua
{
    playerId = {
        currentZone = 1,
        moralityScore = 50,
        weapons = {...},
        items = {...},
        collectibles = {
            recordings = {...},
            photos = {...},
            files = {...},
            diary = {...}
        },
        quests = {M1 = {...}, ...},
        eddieLevel = 1,
        xp = 0,
        stats = {...},
        endingsUnlocked = {},
        settings = {...},
        lastSave = os.time(),
        version = "1.0.0"
    }
}
```

### 5.2 Límites

- **Tamaño:** ~5-10 KB por jugador
- **Límite Roblox:** 10 MB
- **Margen:** 99.9% disponible

---

## 6. Optimización

### 6.1 Rendimiento Target

| Plataforma | FPS | Gráficos | Notas |
|------------|-----|---------|-------|
| PC (Alto) | 60 | Ultra | Sombras, AA, AO |
| PC (Medio) | 60 | Medium | Sombras reducidas |
| Móvil | 30 | Low-Medium | Sin partículas |

### 6.2 Técnicas

1. **Streaming** - Carga dinámica de zonas
2. **LOD** - Modelos simplificados a distancia
3. **Occlusion Culling** - No renderizar lo oculto
4. **Pooling** - Reutilizar instancias de NPCs
5. **Audio** - Máximo 32 fuentes, compresión MP3

---

## 7. Seguridad

### 7.1 Validación Server-Side

- Todo daño calculado en server
- Inventario validado
- Progreso verificado

### 7.2 Anti-Cheat

| Detección | Umbral | Acción |
|-----------|--------|--------|
| Speed Hack | >50 studs/s | Kick |
| Fly Hack | Y inválida | Kick |
| Damage Hack | Daño imposible | Ban |
| Rate Limit | >10 req/s | Temp ban |

---

## 8. Roadmap Técnico

### Fase 1: Pre-Producción (Semanas 1-4)
- [x] Estructura de repositorio
- [x] Módulos base
- [ ] Prototipo Zona 1
- [ ] Combate básico

### Fase 2: Producción Temprana (Semanas 5-12)
- [ ] Zona 1-2 completas
- [ ] Lince implementado
- [ ] Primer jefe

### Fase 3: Producción Principal (Semanas 13-24)
- [ ] Zonas 3-6
- [ ] Todos los Trolelotes
- [ ] Todos los jefes
- [ ] Sistema de finales

### Fase 4: Beta (Semanas 25-32)
- [ ] Testing
- [ ] Bug fixing
- [ ] Lanzamiento

---

## 9. Scripts Pendientes

### 9.1 Prioridad Alta
- [ ] HealthManager.lua
- [ ] DialogueManager.lua
- [ ] CollectibleManager.lua
- [ ] ZoneManager.lua

### 9.2 Prioridad Media
- [ ] MerchantServer.lua (Trolelotes)
- [ ] ShopInterface.lua
- [ ] VoiceHandler.lua
- [ ] FlashlightController.lua

### 9.3 Prioridad Baja
- [ ] AnalyticsServer.lua
- [ ] PerformanceMonitor.lua
- [ ] Tests automatizados

---

## 10. Referencias

- [Documento Narrativo](DOCUMENTO_MAESTRO_NARRATIVA.md)
- [Roblox API](https://create.roblox.com/docs/api)
- [Rojo Documentation](https://rojo.space/)

---

*Última actualización: 18 de Abril, 2026*
