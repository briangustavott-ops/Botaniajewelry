# Arquitectura del sistema

## Principio de diseño

Todo el sistema corre **de forma local** en el PC de la gestora del negocio. No hay servidores externos ni costes de infraestructura. La automatización corre en background mientras ella trabaja en otras tareas.

## Diagrama general

```
PC Windows 11 (host)
│
├── Carpeta media/  (fotos, vídeos — gestionados desde Windows)
│       │
│       └── montada como carpeta compartida
│                   │
└── VMware Workstation
    └── VM: Ubuntu Server 24.04 LTS
        ├── Docker + Docker Compose
        ├── N8N  ──────────────────── orquesta el flujo
        │    │
        │    ├── lee contenido de /media (carpeta compartida)
        │    ├── llama a Claude API (genera textos)
        │    └── publica vía APIs externas
        └── SQLite  ────────────────── registro de publicaciones

                            │ Internet
                            ▼
               ┌────────────┬────────────┐
           Instagram      Web         Etsy
```

## Componentes

### 1. Biblioteca de contenido (host Windows)
- Carpeta local con fotos, vídeos e historias organizados por tipo y producto
- Gestionada directamente por la usuaria desde Windows
- Accesible desde la VM via carpeta compartida VMware

### 2. Máquina virtual (VMware Workstation)
- **SO:** Ubuntu Server 24.04 LTS (sin escritorio, ligera)
- **RAM asignada:** 2 GB
- **CPU:** 2 núcleos
- **Disco:** 20 GB
- Corre en background sin interferir con el trabajo diario

### 3. N8N (dentro de la VM, via Docker)
- Orquestador de workflows
- Interfaz web en `http://localhost:5678` (accesible desde Windows)
- Ejecuta los flujos de publicación según horario programado
- Llama a la API de Claude para generación de contenido
- Llama a las APIs de publicación (Meta, Etsy, web)

### 4. Base de datos (SQLite, dentro de la VM)
- Registro de cada asset: estado, fechas de publicación, plataformas
- Sin servidor separado — archivo único, ligero

### 5. APIs externas
- **Anthropic API** — generación de textos con Claude
- **Meta Graph API** — publicación en Instagram
- **Etsy API v3** — gestión de listings
- **CMS API** — publicación en web propia (por definir según plataforma)

## Flujo de una publicación

```
Cron trigger (ej. lunes 10:00)
    │
    ▼
N8N: consultar SQLite
    → ¿qué assets están disponibles y no publicados?
    │
    ▼
N8N: seleccionar asset
    → criterio: tipo, producto, última publicación
    │
    ▼
N8N: llamar a Claude API
    → prompt: genera caption para Instagram en español
    → Claude devuelve: texto + hashtags + alt-text
    │
    ▼
N8N: publicar en Instagram via Meta Graph API
    │
    ▼
N8N: actualizar SQLite
    → marcar asset como publicado, fecha, plataforma
    │
    ▼
(opcional) Notificación a la usuaria
```

## Portabilidad

La VM se exporta como `.ova` y se importa en el PC de la usuaria con **VMware Player (gratuito)**. Solo requiere:
- Instalar VMware Player
- Importar el archivo `.ova`
- Configurar la carpeta compartida apuntando a su carpeta de medios
- Añadir las claves API en el archivo `.env`
