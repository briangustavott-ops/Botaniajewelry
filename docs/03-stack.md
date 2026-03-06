# Stack tecnológico

## Resumen

| Capa | Herramienta | Versión | Coste |
|------|-------------|---------|-------|
| Virtualización | VMware Workstation / Player | Última | Gratis (Player) |
| SO invitado | Ubuntu Server LTS | 24.04 | Gratis |
| Contenedores | Docker + Docker Compose | Última | Gratis |
| Orquestación | N8N | Última | Gratis (self-hosted) |
| Base de datos | SQLite | 3.x | Gratis |
| IA (pruebas) | Claude Desktop | — | Gratis |
| IA (producción) | Anthropic API (Claude) | — | Pay-as-you-go |
| Publicación | Meta Graph API | v21 | Gratis (límites de uso) |
| Publicación | Etsy API | v3 | Gratis |
| Publicación | CMS API web | — | Por definir |

## Detalle por componente

### VMware Workstation / Player
- **Workstation:** para desarrollo y configuración (ya instalado)
- **Player:** versión gratuita para la usuaria final
- Exportación en formato `.ova` compatible entre ambos
- Carpetas compartidas para acceso a medios desde Windows

### Ubuntu Server 24.04 LTS
- Sin interfaz gráfica — reduce consumo de recursos
- Soporte garantizado hasta 2029
- Ideal para correr servicios Docker en background

### Docker + Docker Compose
- N8N se despliega con imagen oficial: `n8nio/n8n`
- `docker-compose.yml` define todos los servicios
- Facilita actualizaciones y configuración reproducible

### N8N
- Interfaz visual para crear workflows sin código complejo
- Nodos nativos para HTTP, cron, condicionales, transformaciones
- Accesible desde el navegador de Windows en `http://localhost:5678`
- Workflows exportables como JSON (versionados en este repositorio)

### SQLite
- Base de datos de un solo archivo, sin servidor
- Almacena el catálogo de assets y el historial de publicaciones
- Backup = copiar un archivo

### Anthropic API (Claude)
- Modelo recomendado: `claude-haiku-4-5` para generación de textos (económico y rápido)
- Modelo alternativo: `claude-sonnet-4-6` para mayor calidad
- Coste estimado: ~€5-15/mes según volumen de publicaciones

### Meta Graph API
- Requiere cuenta de Instagram **Business o Creator**
- Requiere página de Facebook vinculada
- Permite publicar: imágenes, carruseles, Reels, Stories
- Token de acceso de larga duración (60 días, renovable)

### Etsy API v3
- Autenticación OAuth 2.0
- Permite: leer y actualizar listings, subir fotos, modificar descripciones
- Limitación: creación masiva de listings requiere revisión por Etsy

## Variables de entorno (.env)

```env
# IA
ANTHROPIC_API_KEY=

# Meta / Instagram
META_ACCESS_TOKEN=
META_INSTAGRAM_ACCOUNT_ID=

# Etsy
ETSY_API_KEY=
ETSY_SHOP_ID=

# Web
WEB_API_URL=
WEB_API_KEY=
```

> El archivo `.env` nunca se sube al repositorio. Ver `.env.example` para la plantilla.
