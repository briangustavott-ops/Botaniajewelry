# Stack tecnológico

## Resumen

| Capa | Herramienta | Coste |
|------|-------------|-------|
| Virtualización | VMware Workstation / Player | Gratis (Player) |
| SO invitado | Ubuntu Server 24.04 LTS | Gratis |
| Contenedores | Docker + Docker Compose | Gratis |
| Orquestación | N8N (self-hosted) | Gratis |
| Frontend | FastAPI + HTML/JS | Gratis |
| Base de datos | SQLite | Gratis |
| Almacenamiento en nube | Google Drive (15 GB gratis) | Gratis |
| IA — análisis visual | Anthropic API · Claude Vision | Pay-as-you-go |
| IA — generación de texto | Anthropic API · Claude | Pay-as-you-go |
| IA — generación de imágenes | Flux via Replicate | Pay-as-you-go |
| IA (pruebas iniciales) | Claude Desktop | Gratis |
| Publicación | Meta Graph API (Instagram) | Gratis |
| Publicación | Etsy API v3 | Gratis |
| Publicación | CMS API (web propia) | Por definir |

**Coste mensual estimado:** ~€10–20/mes (solo APIs de IA, según volumen de uso)

---

## Detalle por componente

### VMware Workstation / Player
- **Workstation:** para desarrollo y configuración (ya instalado)
- **Player:** versión gratuita para la usuaria final
- Exportación en formato `.ova` — portable entre ambos
- La VM arranca en background al encender el PC

### Ubuntu Server 24.04 LTS
- Sin interfaz gráfica — reduce consumo de recursos
- Soporte garantizado hasta 2029
- Todos los servicios corren como contenedores Docker

### Docker + Docker Compose
- Servicios definidos en `docker-compose.yml`
- Contenedores: N8N, Frontend (FastAPI), SQLite volume
- Arranque automático con `restart: unless-stopped`

### Google Drive
- La gestora sube contenido desde el móvil o cualquier dispositivo
- N8N monitoriza carpetas específicas con el nodo **Google Drive Trigger**
- Carpetas organizadas por destino: `entrada/`, `instagram/`, `etsy/`, `web/`, `todos/`
- 15 GB gratuitos — suficiente para el volumen del negocio

### N8N
- Orquestador visual de workflows
- Interfaz de administración: `http://localhost:5678`
- Nodos clave utilizados: Google Drive, HTTP Request, Claude, Cron, SQLite, Webhook
- Workflows exportados como JSON y versionados en `workflows/`

### FastAPI + HTML/JS (Frontend)
- API backend en Python con FastAPI
- Frontend HTML/CSS/JS servido por FastAPI (sin framework JS complejo)
- Accesible en `http://localhost:3000`
- Se comunica con N8N via webhooks y con SQLite directamente
- Estructura:
  ```
  frontend/
  ├── main.py           # FastAPI — rutas y lógica
  ├── templates/        # HTML por sección
  ├── static/           # CSS + JS
  └── Dockerfile
  ```

### Anthropic API (Claude)

| Uso | Modelo recomendado | Motivo |
|-----|--------------------|--------|
| Análisis de imagen (Vision) | `claude-opus-4-5` | Mayor precisión en detección de producto |
| Generación de texto (captions, listings) | `claude-haiku-4-5` | Rápido y económico |
| Uso manual / pruebas | Claude Desktop | Sin coste adicional |

- **Claude Vision:** analiza imágenes → detecta tipo de pieza, colores, materiales, sugiere plataforma y genera texto
- **Claude texto:** genera captions ES/EN, hashtags, listings completos de Etsy

### Flux via Replicate (generación de imágenes)
- Modelo fotorrealista ideal para joyería
- Precio: ~€0.003 por imagen generada
- Se llama desde N8N via HTTP Request al disparar un webhook del frontend o Claude Desktop
- La imagen generada se guarda en `media/generadas/` y se registra en SQLite

### Meta Graph API
- Requiere cuenta Instagram **Business o Creator** + página de Facebook vinculada
- Permite: publicar imágenes, carruseles, Reels, Stories
- Token de larga duración: 60 días (renovable desde el panel ⚙️ del frontend)

### Etsy API v3
- Autenticación OAuth 2.0
- Permite: crear listings (draft + publish), subir fotos, actualizar título/descripción/tags/precio
- Creación de listings desde el frontend con texto generado por IA en inglés

### SQLite
- Base de datos de un único archivo, sin servidor
- Reside en la VM dentro de un volumen Docker
- Backup = copiar el archivo `assets.db`

---

## Variables de entorno (.env)

```env
# ═══ IA ═══
ANTHROPIC_API_KEY=

# ═══ Meta / Instagram ═══
META_ACCESS_TOKEN=
META_INSTAGRAM_ACCOUNT_ID=

# ═══ Etsy ═══
ETSY_API_KEY=
ETSY_API_SECRET=
ETSY_SHOP_ID=

# ═══ Google Drive ═══
GOOGLE_DRIVE_CREDENTIALS_JSON=
GOOGLE_DRIVE_FOLDER_ID_ENTRADA=
GOOGLE_DRIVE_FOLDER_ID_INSTAGRAM=
GOOGLE_DRIVE_FOLDER_ID_ETSY=

# ═══ Web propia ═══
WEB_API_URL=
WEB_API_KEY=

# ═══ Generación de imágenes ═══
REPLICATE_API_TOKEN=

# ═══ N8N ═══
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=
```

> El archivo `.env` nunca se sube al repositorio. Ver `.env.example` para la plantilla.
