# Setup 03 — Base de datos SQLite

## Requisitos previos

- N8N corriendo en la VM (ver [Setup 02](02-n8n.md))
- `sqlite3` disponible en la VM

---

## 1. Instalar sqlite3 en la VM

```bash
sudo apt install -y sqlite3
sqlite3 --version
```

---

## 2. Clonar el repositorio en la VM

El esquema SQL está versionado en el repositorio. Clonarlo en la VM:

```bash
cd ~
git clone https://github.com/briangustavott-ops/Botaniajewelry.git botania-repo
```

> Si ya existe, actualizar: `cd ~/botania-repo && git pull`

---

## 3. Inicializar la base de datos

```bash
bash ~/botania-repo/database/init.sh
```

Salida esperada:
```
✅ Base de datos creada en /home/bjadmin/botania/data/db/assets.db

Tablas creadas:
assets  publicaciones

Vistas creadas:
assets_disponibles
bandeja_revision
```

---

## 4. Verificar el esquema

```bash
sqlite3 ~/botania/data/db/assets.db
```

Dentro de la consola SQLite:
```sql
.tables
.schema assets
.schema publicaciones
SELECT * FROM assets_disponibles;
.quit
```

---

## 5. Montar la BD en el contenedor N8N

Para que N8N pueda acceder a la base de datos, hay que montar la carpeta `data/db` como volumen en el contenedor.

Editar `~/botania/docker-compose.yml`:

```bash
nano ~/botania/docker-compose.yml
```

Añadir el volumen de la BD en el servicio N8N:

```yaml
services:

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - N8N_HOST=${VM_IP}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://${VM_IP}:5678/
      - GENERIC_TIMEZONE=Europe/Madrid
      - TZ=Europe/Madrid
      - N8N_SECURE_COOKIE=false
    volumes:
      - ./data/n8n:/home/node/.n8n
      - ./data/db:/data/db        # ← Añadir esta línea
```

Reiniciar N8N para aplicar el cambio:

```bash
cd ~/botania
docker compose restart n8n
```

A partir de ahora, en los workflows de N8N la ruta a la base de datos es:
```
/data/db/assets.db
```

---

## 6. Probar desde N8N

En un workflow de N8N, añadir un nodo **SQLite** con:
- **Database file:** `/data/db/assets.db`
- **Operation:** Execute Query
- **Query:** `SELECT name FROM sqlite_master WHERE type='table';`

Debe devolver `assets` y `publicaciones`.

---

## Estructura de tablas

### `assets` — Catálogo de contenido multimedia

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER PK | Identificador único |
| `archivo` | TEXT | Ruta del archivo en la VM |
| `tipo` | TEXT | `foto`, `video`, `reel`, `historia`, `captura`, `generada` |
| `categoria` | TEXT | `pendientes`, `anillos`, `colgantes` |
| `origen` | TEXT | `drive_movil`, `frontend_pc`, `ia_generada`, `email_captura` |
| `caption_es` | TEXT | Caption en español (generado por IA) |
| `caption_en` | TEXT | Caption en inglés (generado por IA) |
| `hashtags` | TEXT | Hashtags sugeridos |
| `plataformas_destino` | TEXT | `instagram,etsy,web` |
| `estado` | TEXT | Ver ciclo de vida más abajo |
| `fecha_subida` | DATETIME | Cuándo llegó al sistema |

### `publicaciones` — Historial de publicaciones

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INTEGER PK | Identificador único |
| `asset_id` | INTEGER FK | Referencia al asset |
| `plataforma` | TEXT | `instagram`, `web`, `etsy` |
| `fecha` | DATETIME | Cuándo se publicó |
| `url_publicacion` | TEXT | URL del post |
| `estado` | TEXT | `ok` o `error` |

### Ciclo de vida de un asset

```
subido → analizando → pendiente_revision → disponible → programado → publicado
                   ↘ error_analisis ↗
```

### Vistas útiles para N8N

| Vista | Uso |
|-------|-----|
| `assets_disponibles` | Assets listos para publicar con fecha de última publicación |
| `bandeja_revision` | Assets pendientes de aprobación (para el frontend) |

---

## Backup

```bash
# Copiar la BD a un lugar seguro
cp ~/botania/data/db/assets.db ~/botania/data/db/assets.db.bak

# O comprimir
sqlite3 ~/botania/data/db/assets.db ".backup '/tmp/assets_backup.db'"
```
