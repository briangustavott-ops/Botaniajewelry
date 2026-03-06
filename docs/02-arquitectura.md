# Arquitectura del sistema

## Principio de diseño

Todo el sistema corre **de forma local** en el PC de la gestora. No hay servidores externos ni costes de infraestructura. La automatización corre en background mientras ella trabaja en otras tareas.

El contenido multimedia llega al sistema por **dos vías**:
- **Desde el móvil:** subida a Google Drive → N8N lo detecta y descarga → IA lo analiza
- **Desde el PC:** subida directa a través del frontend con asistencia de IA

## Diagrama general

```
MÓVIL (gestora)                        PC (gestora)
      │                                     │
      ▼                                     ▼
Google Drive ─────────────────────► Frontend (localhost:3000)
      │                                     │
      │         VM Ubuntu (background)      │
      └──────────────────────────────────┐  │
                                         ▼  ▼
                               ┌──────── N8N (:5678) ────────┐
                               │              │               │
                               ▼              ▼               ▼
                          Descargar      Orquestar        Webhooks
                          de Drive       workflows        del frontend
                               │              │
                               ▼              ▼
                          Claude API     Meta / Etsy / Web APIs
                               │
                               ▼
                            SQLite
                      (catálogo + historial)
                               │
                               ▼
                    ┌──────────┬──────────┐
                Instagram     Web        Etsy
```

## Componentes

### 1. Google Drive (fuente de contenido móvil)
- La gestora sube fotos y vídeos desde el móvil a carpetas organizadas por destino
- N8N monitoriza la carpeta (nodo Google Drive Watch) en intervalos configurables
- Al detectar un archivo nuevo: lo descarga a `media/` en la VM y lanza el análisis IA
- Google Drive API incluida en N8N sin configuración adicional

Estructura de carpetas en Drive:
```
Google Drive / Botania /
├── entrada/      ← IA decide el destino
├── instagram/    ← Solo Instagram
├── etsy/         ← Solo Etsy
├── web/          ← Solo web
└── todos/        ← Todas las plataformas
```

### 2. Frontend web (panel de control)
- **Tecnología:** FastAPI + HTML/JS, contenedor Docker
- **Acceso:** `http://localhost:3000` desde el navegador de Windows
- **Funciones:** subir contenido, revisar sugerencias IA, publicar, crear productos Etsy, gestionar APIs
- Se comunica con N8N mediante webhooks y con SQLite directamente

### 3. Máquina virtual (VMware Workstation)
- **SO:** Ubuntu Server 24.04 LTS (sin escritorio, ligera)
- **RAM asignada:** 2 GB
- **CPU:** 2 núcleos
- **Disco:** 20 GB
- Corre en background sin interferir con el trabajo diario
- Exportable como `.ova` para instalar en el PC de la usuaria final

### 4. N8N (dentro de la VM, via Docker)
- Orquestador principal de todos los flujos
- Interfaz de administración en `http://localhost:5678`
- Workflows exportados como JSON y versionados en este repositorio

### 5. Claude API (Anthropic)
- **Claude Vision:** analiza imágenes → detecta tipo de joya, colores, materiales, plataforma sugerida
- **Claude texto:** genera captions, hashtags, alt-text, listings de Etsy en EN/ES
- Llamado desde N8N (flujos automáticos) y desde el frontend (petición manual)

### 6. Base de datos (SQLite)
- Catálogo completo de assets con metadatos y estado
- Historial de publicaciones por plataforma
- Sin servidor — archivo único, backup trivial

### 7. APIs externas de publicación
- **Meta Graph API** — Instagram posts, Reels, Stories
- **Etsy API v3** — crear y actualizar listings
- **CMS API** — web propia (por definir según plataforma)

## Flujos principales

### Flujo A — Subida desde móvil (automático)
```
Gestora sube foto a Google Drive (carpeta destino)
    ↓
N8N detecta el archivo (Watch node, cada 5 min)
    ↓
N8N descarga el archivo a media/ en la VM
    ↓
N8N llama a Claude Vision: analiza imagen
    → detecta: tipo, colores, materiales, plataforma sugerida
    → genera: caption ES + EN, hashtags, alt-text
    ↓
N8N guarda en SQLite: estado = "pendiente_revision" + sugerencias
    ↓
Frontend muestra el asset en la Bandeja de revisión
    ↓
Gestora aprueba / edita → estado = "disponible"
```

### Flujo B — Publicación automática programada
```
Cron trigger (ej. lunes y jueves, 10:00)
    ↓
N8N consulta SQLite: assets disponibles, no publicados recientemente
    ↓
N8N selecciona asset (criterio: categoría, antigüedad, plataformas)
    ↓
N8N llama a Claude: genera caption final optimizado para la plataforma
    ↓
N8N publica via API (Instagram / Web / Etsy)
    ↓
N8N actualiza SQLite: estado = "publicado", fecha, url
    ↓
(opcional) Notificación a la gestora
```

### Flujo C — Publicación manual desde el frontend
```
Gestora selecciona asset en el frontend
    ↓
Elige plataforma y revisa/edita caption generado por IA
    ↓
Hace clic en "Publicar"
    ↓
Frontend llama a webhook de N8N
    ↓
N8N ejecuta la publicación y actualiza SQLite
```

### Flujo D — Nuevo producto en Etsy
```
Gestora selecciona fotos de la biblioteca en el frontend
    ↓
Hace clic en "Generar listing con IA"
    ↓
Claude Vision analiza las fotos → genera: título EN, descripción EN, tags
    ↓
Gestora revisa, añade precio y stock
    ↓
[Crear borrador] → crea draft en Etsy via API
    ↓
Gestora revisa en Etsy.com → [Publicar]
```

## Selección de plataforma por IA

Claude Vision sugiere el destino del contenido basándose en el análisis de la imagen:

| Características | Destino sugerido |
|-----------------|-----------------|
| Fondo neutro, producto centrado, buena iluminación | Etsy + Web |
| Ambiente natural, lifestyle, composición estética | Instagram |
| Formato vertical 9:16 | Instagram Stories |
| Vídeo corto de proceso o making-of | Instagram Reel |
| Foto cuadrada, producto sobre fondo blanco | Etsy + Instagram |

La gestora puede cambiar el destino durante la revisión en la Bandeja.

## Portabilidad

La VM se exporta como `.ova` y se importa en el PC de la usuaria con **VMware Player (gratuito)**:
1. Instalar VMware Player en el PC de la usuaria
2. Importar el archivo `.ova`
3. Añadir las claves API en el archivo `.env`
4. Configurar las credenciales de Google Drive
5. Arrancar la VM — el sistema arranca automáticamente
