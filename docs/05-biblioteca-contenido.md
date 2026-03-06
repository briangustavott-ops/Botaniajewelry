# Biblioteca de contenido

## Principio

La biblioteca vive en el PC de Windows (host), en una carpeta compartida accesible desde la VM. La gestora añade contenido directamente desde Windows; N8N lo lee y publica desde la VM.

## Estructura de carpetas

```
media/
├── fotos/
│   ├── pendientes/
│   ├── anillos/
│   └── colgantes/
├── videos/
│   ├── proceso/        ← cómo se hacen las piezas
│   ├── producto/       ← vídeos de producto final
│   └── reels/
├── historias/          ← contenido para Instagram Stories
└── _publicado/         ← (opcional) mover aquí tras publicar
```

## Base de datos de assets (SQLite)

### Tabla: `assets`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER PK | Identificador único |
| `archivo` | TEXT | Ruta relativa al archivo |
| `tipo` | TEXT | `foto`, `video`, `reel`, `historia` |
| `categoria` | TEXT | `pendientes`, `anillos`, `colgantes` |
| `descripcion` | TEXT | Descripción breve del producto |
| `colores` | TEXT | Colores predominantes |
| `materiales` | TEXT | Materiales (resina, flores, etc.) |
| `idiomas` | TEXT | `es`, `en`, `es,en` |
| `estado` | TEXT | `disponible`, `programado`, `publicado` |
| `fecha_creacion` | DATE | Cuándo se añadió a la biblioteca |

### Tabla: `publicaciones`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER PK | Identificador único |
| `asset_id` | INTEGER FK | Referencia al asset |
| `plataforma` | TEXT | `instagram`, `web`, `etsy` |
| `fecha` | DATETIME | Cuándo se publicó |
| `url_publicacion` | TEXT | URL del post publicado |
| `caption_generado` | TEXT | Texto generado por la IA |
| `estado` | TEXT | `ok`, `error` |
| `error_detalle` | TEXT | Detalle del error si aplica |

## Convención de nombres de archivo

```
[categoria]_[descripcion-corta]_[numero].jpg
```

Ejemplos:
```
pendientes_flores-azules-resina_001.jpg
anillo_margarita-esfera_001.mp4
colgante_gota-lavanda_001.jpg
```

## Flujo de adición de contenido

```
Gestora hace fotos/vídeos del producto
    │
    ▼
Copia archivos a la carpeta media/ en Windows
    │
    ▼
(opcional) Registra el asset en la BD con sus metadatos
    │
    ▼
N8N detecta nuevos assets disponibles en el próximo ciclo
    │
    ▼
Asset entra en la cola de publicación
```

## Reglas de selección de contenido

- No repetir el mismo asset en la misma plataforma en menos de 30 días
- Alternar categorías (no publicar pendientes 5 veces seguidas)
- Priorizar contenido sin publicar sobre contenido ya publicado en otras plataformas
- En temporadas especiales (Navidad, San Valentín), priorizar assets etiquetados para esa temporada
