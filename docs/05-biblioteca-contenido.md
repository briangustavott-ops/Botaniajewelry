# Biblioteca de contenido

## Principio

El contenido llega al sistema por dos vías y siempre pasa por revisión antes de entrar en la cola de publicación:

```
MÓVIL                               PC
  │                                  │
  ▼                                  ▼
Google Drive                    Frontend (subir)
  │                                  │
  └──────────────┬───────────────────┘
                 ▼
        N8N descarga y analiza
        Claude Vision → sugerencias
                 │
                 ▼
        SQLite: pendiente_revision
                 │
        Gestora revisa en frontend
                 │
                 ▼
        SQLite: disponible
                 │
        N8N publica según programa
```

---

## Estructura de carpetas en Google Drive

La gestora organiza el contenido en carpetas según el destino deseado al subir desde el móvil:

```
Google Drive / Botania /
├── entrada/       ← IA decide el destino según el análisis
├── instagram/     ← Solo Instagram (posts, reels, stories)
├── etsy/          ← Solo Etsy (fotos de producto)
├── web/           ← Solo web propia
└── todos/         ← Todas las plataformas
```

Si no sabe el destino, la gestora sube a `entrada/` y la IA lo clasifica automáticamente.

---

## Estructura de carpetas local (VM)

Una vez descargado de Drive o subido desde el frontend, el archivo se organiza en la VM:

```
media/
├── fotos/
│   ├── pendientes/
│   ├── anillos/
│   └── colgantes/
├── videos/
│   ├── proceso/          ← making-of, técnica de resina
│   ├── producto/         ← vídeos de producto final
│   └── reels/
├── historias/            ← contenido para Instagram Stories
├── capturas/             ← capturas de comentarios Etsy / menciones IG
└── generadas/            ← imágenes creadas por IA (Flux / DALL-E)
```

---

## Estados de un asset

```
subido
  │
  ▼
analizando          ← Claude Vision procesa la imagen
  │           │
  ▼           ▼
pendiente_revision  error_analisis  ← imagen no procesable (baja res, etc.)
  │
  ▼ (gestora aprueba en frontend)
disponible
  │
  ▼ (N8N lo selecciona o gestora publica manualmente)
programado
  │
  ▼
publicado
```

---

## Base de datos de assets (SQLite)

### Tabla: `assets`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER PK | Identificador único |
| `archivo` | TEXT | Ruta relativa en la VM (`media/fotos/pendientes/...`) |
| `nombre_original` | TEXT | Nombre original del archivo |
| `tipo` | TEXT | `foto`, `video`, `reel`, `historia`, `captura`, `generada` |
| `categoria` | TEXT | `pendientes`, `anillos`, `colgantes` |
| `origen` | TEXT | `drive_movil`, `frontend_pc`, `ia_generada`, `email_captura` |
| `descripcion` | TEXT | Descripción del producto |
| `colores` | TEXT | Colores detectados por IA |
| `materiales` | TEXT | Materiales detectados por IA |
| `caption_es` | TEXT | Caption sugerido en español |
| `caption_en` | TEXT | Caption sugerido en inglés |
| `hashtags` | TEXT | Hashtags sugeridos |
| `plataformas_destino` | TEXT | `instagram`, `etsy`, `web` (separadas por coma) |
| `idiomas` | TEXT | `es`, `en`, `es,en` |
| `estado` | TEXT | `subido`, `analizando`, `pendiente_revision`, `error_analisis`, `disponible`, `programado`, `publicado` |
| `error_detalle` | TEXT | Descripción del error si `estado = error_analisis` |
| `fecha_subida` | DATETIME | Cuándo llegó al sistema |
| `fecha_aprobacion` | DATETIME | Cuándo la gestora lo aprobó |

### Tabla: `publicaciones`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER PK | Identificador único |
| `asset_id` | INTEGER FK | Referencia al asset |
| `plataforma` | TEXT | `instagram`, `web`, `etsy` |
| `fecha` | DATETIME | Cuándo se publicó |
| `url_publicacion` | TEXT | URL del post publicado |
| `caption_usado` | TEXT | Texto final publicado (puede diferir de la sugerencia) |
| `estado` | TEXT | `ok`, `error` |
| `error_detalle` | TEXT | Detalle del error si aplica |

---

## Convención de nombres de archivo

```
[categoria]_[descripcion-corta]_[NNN].[ext]
```

Ejemplos:
```
pendientes_flores-azules-resina_001.jpg
anillo_margarita-esfera_001.mp4
colgante_gota-lavanda_001.jpg
captura_comentario-etsy_001.png
generada_pendientes-campo_001.jpg
```

---

## Reglas de selección automática de contenido

Cuando N8N ejecuta una publicación programada, selecciona el asset siguiente según estas prioridades:

1. Estado `disponible` (nunca publicado)
2. No repetir la misma categoría más de 2 veces seguidas
3. No publicar el mismo asset en la misma plataforma en menos de 30 días
4. En temporadas especiales (Navidad, San Valentín, Primavera), priorizar assets etiquetados para esa temporada
5. Alternar entre fotos y vídeos cuando haya disponibles de ambos tipos
