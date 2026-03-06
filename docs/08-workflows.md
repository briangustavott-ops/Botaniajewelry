# Diseño de workflows N8N

## Arquitectura general

El sistema tiene dos canales de entrada y dos de salida, gestionados por **7 workflows**:

```
ENTRADA MÓVIL              ENTRADA PC (Frontend)
       │                           │
[W1 drive-monitor]       [W5 frontend-upload]
       │                           │
       └────────────┬──────────────┘
                    │
           [W2 asset-analyzer]        ← subworkflow compartido
            (Claude Vision)
                    │
                 SQLite
           (pendiente_revision)
                    │
       ┌────────────┴────────────┐
       │                         │
[W4 frontend-review]    [W3 auto-publisher]  ← cron horario
(bandeja de revisión)            │
       │              [W6 frontend-publish]  ← botón frontend
       │                         │
       └──► disponible ──────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
               Instagram                     Web
                    │                         │
                    └────────────┬────────────┘
                                 │
                        [W7 notifier]          ← subworkflow compartido
                      (Telegram / email)
```

---

## Tabla de workflows

| ID | Nombre | Trigger | Resumen |
|----|--------|---------|---------|
| W1 | `drive-monitor` | Google Drive Trigger | Detecta archivos nuevos en Drive, los descarga a la VM, inserta en SQLite, llama a W2 |
| W2 | `asset-analyzer` | Webhook (llamado por W1 y W5) | Claude Vision analiza la imagen y actualiza SQLite con sugerencias de IA |
| W3 | `auto-publisher` | Cron (cada hora, lógica interna) | Lee config de SQLite, publica según programación, llama a W7 |
| W4 | `frontend-review` | Webhook | Recibe acciones de la bandeja: aprobar, editar, descartar |
| W5 | `frontend-upload` | Webhook | Recibe archivo subido desde PC, guarda en VM, llama a W2 |
| W6 | `frontend-publish` | Webhook | Publica inmediatamente o programa un asset desde el frontend, llama a W7 |
| W7 | `notifier` | Webhook (llamado por W3 y W6) | Envía notificación por Telegram y/o email tras cualquier publicación |

---

## W1 — `drive-monitor`

**Trigger:** Google Drive Trigger — monitoriza la carpeta `entrada/` (poll cada 5 min)

```
Google Drive Trigger
  │
  ├─ Descarga archivo  →  media/fotos/pendientes/{timestamp}_{nombre}
  ├─ INSERT SQLite:
  │     archivo, nombre_original, tipo='foto', origen='drive_movil'
  │     estado='subido'
  └─ HTTP Request  →  POST /webhook/analyze-asset  { asset_id }
```

**Nodos N8N:** Google Drive Trigger · Google Drive (download) · SQLite · HTTP Request

---

## W2 — `asset-analyzer` *(subworkflow)*

**Trigger:** Webhook `POST /webhook/analyze-asset`
**Input:** `{ asset_id }`

```
Webhook
  │
  ├─ SELECT * FROM assets WHERE id = asset_id
  ├─ UPDATE estado → 'analizando'
  ├─ HTTP Request → Claude API (Vision)
  │     Prompt: analiza tipo de joya, colores, materiales,
  │             sugiere caption ES+EN, hashtags, plataformas_destino
  ├─ Code node: parsea respuesta JSON de Claude
  ├─ UPDATE SQLite:
  │     tipo, categoria, colores, materiales
  │     caption_es, caption_en, hashtags
  │     plataformas_destino
  │     estado → 'pendiente_revision'
  │     (si error Claude → estado = 'error_analisis', error_detalle)
  └─ Respond to Webhook: { ok: true }
```

**Nodos N8N:** Webhook · SQLite · HTTP Request (Claude) · Code · SQLite · Respond to Webhook

---

## W3 — `auto-publisher`

**Trigger:** Schedule (cron cada hora)
**Lógica:** el cron se ejecuta cada hora; internamente consulta la configuración para decidir si toca publicar.

```
Schedule Trigger (cada hora)
  │
  ├─ SELECT configuracion  →  obtiene programación por plataforma
  │     instagram: activo, posts_semana, horario, dias
  │     web: activo, posts_semana, horario, dias
  │
  ├─ Code node: ¿toca publicar ahora?
  │     - ¿El día de hoy está en los días configurados?
  │     - ¿La hora actual coincide con el horario (±30 min)?
  │     - ¿Las publicaciones esta semana < posts_semana?
  │
  ├─ Para cada plataforma que toca:
  │     ├─ SELECT FROM assets_disponibles
  │     │     WHERE plataformas_destino LIKE '%{plataforma}%'
  │     │     ORDER BY fecha_aprobacion ASC LIMIT 1
  │     │
  │     ├─ Publica en la API correspondiente:
  │     │     instagram → Meta Graph API (image upload + publish)
  │     │     web       → CMS API
  │     │
  │     ├─ INSERT publicaciones (asset_id, plataforma, url, estado)
  │     ├─ UPDATE assets SET estado = 'publicado'
  │     └─ HTTP Request → POST /webhook/notify { resultado }
  │
  └─ Si no toca publicar → fin (sin acción)
```

> Si falla la publicación en una plataforma, el error se registra en `publicaciones.estado = 'error'` y se notifica igualmente. El asset permanece en `disponible` para el siguiente intento.

**Nodos N8N:** Schedule Trigger · SQLite · Code · IF · HTTP Request (Meta/CMS) · SQLite · HTTP Request (notify)

### Configuración de programación (tabla `configuracion`)

La gestora define la programación desde el Frontend. Los valores se leen en cada ejecución del cron:

| Clave | Valor por defecto | Descripción |
|-------|------------------|-------------|
| `instagram_activo` | `1` | Publicación automática en Instagram activa |
| `instagram_posts_semana` | `3` | Máximo de publicaciones automáticas por semana |
| `instagram_horario` | `10:00` | Hora preferida de publicación |
| `instagram_dias` | `1,3,5` | Días de la semana (1=lun … 7=dom) |
| `web_activo` | `1` | Publicación automática en web activa |
| `web_posts_semana` | `2` | Máximo de publicaciones automáticas por semana |
| `web_horario` | `11:00` | Hora preferida de publicación |
| `web_dias` | `2,4` | Días de la semana para web |

---

## W4 — `frontend-review`

**Trigger:** Webhook `POST /webhook/review-action`
**Input:** `{ asset_id, accion, cambios? }`

```
Webhook
  │
  ├─ accion = "aprobar"
  │     ├─ Aplica cambios opcionales (caption_es, caption_en, hashtags,
  │     │    plataformas_destino) si vienen en el payload
  │     └─ UPDATE assets:
  │           estado → 'disponible'
  │           fecha_aprobacion = CURRENT_TIMESTAMP
  │
  ├─ accion = "descartar"
  │     └─ UPDATE assets SET estado = 'descartado'
  │
  └─ Respond to Webhook: { ok: true, estado_nuevo }
```

**Nodos N8N:** Webhook · Switch · SQLite · Respond to Webhook

---

## W5 — `frontend-upload`

**Trigger:** Webhook `POST /webhook/upload-asset`
**Input:** archivo (binary) + metadatos opcionales (descripcion, categoria)

```
Webhook
  │
  ├─ Guarda archivo  →  media/fotos/pendientes/{timestamp}_{nombre}
  ├─ INSERT SQLite:
  │     archivo, nombre_original, tipo='foto', origen='frontend_pc'
  │     descripcion (si viene), categoria (si viene)
  │     estado='subido'
  ├─ HTTP Request  →  POST /webhook/analyze-asset  { asset_id }
  └─ Respond to Webhook: { asset_id, ok: true }
```

**Nodos N8N:** Webhook · Write Binary File · SQLite · HTTP Request · Respond to Webhook

---

## W6 — `frontend-publish`

**Trigger:** Webhook `POST /webhook/publish-asset`
**Input:** `{ asset_id, plataforma, inmediato: bool }`

```
Webhook
  │
  ├─ SELECT * FROM assets WHERE id = asset_id AND estado = 'disponible'
  ├─ Si no disponible → error 400
  │
  ├─ Si inmediato = true:
  │     ├─ UPDATE estado → 'programado'
  │     ├─ Publica en plataforma (Meta API / CMS API / Etsy API)
  │     ├─ INSERT publicaciones (asset_id, plataforma, url, caption_usado, estado)
  │     ├─ UPDATE estado → 'publicado'
  │     └─ HTTP Request → POST /webhook/notify { resultado }
  │
  └─ Respond to Webhook: { ok: true, url_publicacion? }
```

> La publicación en **Etsy** siempre pasa por este workflow (W6), ya que se inicia manualmente desde el frontend. No existe publicación automática de Etsy en W3.

**Nodos N8N:** Webhook · SQLite · IF · HTTP Request (Meta/CMS/Etsy) · SQLite · HTTP Request (notify) · Respond to Webhook

---

## W7 — `notifier` *(subworkflow)*

**Trigger:** Webhook `POST /webhook/notify`
**Input:** `{ plataforma, asset_id, estado, url_publicacion?, error_detalle? }`

```
Webhook
  │
  ├─ SELECT asset (para incluir tipo, categoria, caption en el mensaje)
  ├─ Formatea mensaje:
  │     ✅ Publicación exitosa en {plataforma}     (si ok)
  │     ❌ Error al publicar en {plataforma}        (si error)
  │     📸 {tipo} · {categoria}
  │     📝 Caption: {caption_usado[:80]}...
  │     🔗 {url_publicacion}  (si disponible)
  │     ⚠️ {error_detalle}   (si error)
  │
  ├─ SELECT notif_telegram_chat_id, notif_telegram_token FROM configuracion
  ├─ Si configurado → Telegram (Send Message)
  │
  ├─ SELECT notif_email FROM configuracion
  ├─ Si configurado → Send Email (SMTP)
  │
  └─ Respond to Webhook: { ok: true }
```

> Se puede configurar Telegram, email o ambos. Si ambas claves están vacías, W7 finaliza sin acción.

**Nodos N8N:** Webhook · SQLite · Code · IF · Telegram · Send Email · Respond to Webhook

### Claves de configuración para notificaciones

| Clave | Descripción |
|-------|-------------|
| `notif_telegram_token` | Bot token de Telegram (vacío = Telegram desactivado) |
| `notif_telegram_chat_id` | Chat ID del destinatario |
| `notif_email` | Dirección de email (vacío = email desactivado) |
| `notif_email_smtp_host` | Servidor SMTP |
| `notif_email_smtp_user` | Usuario SMTP |
| `notif_email_smtp_pass` | Contraseña SMTP |

> **Recomendación:** Telegram es más sencillo de configurar (solo token + chat_id, sin SMTP) y llega al móvil de forma instantánea.

---

## Endpoints webhook expuestos por N8N

| Endpoint | Llamado por | Workflow |
|----------|-------------|----------|
| `POST /webhook/analyze-asset` | W1, W5 | W2 |
| `POST /webhook/review-action` | Frontend | W4 |
| `POST /webhook/upload-asset` | Frontend | W5 |
| `POST /webhook/publish-asset` | Frontend | W6 |
| `POST /webhook/notify` | W3, W6 | W7 |

---

## Cambios de schema requeridos

### 1. Estado `descartado` en `assets`

Añadir al CHECK de `assets.estado`:
```sql
'descartado'  -- Asset revisado y descartado por la gestora
```

Ciclo de vida actualizado:
```
subido → analizando → pendiente_revision → disponible → programado → publicado
                    ↘ error_analisis ↗         ↘ descartado
```

### 2. Tabla `configuracion`

Almacena la programación de publicación y la configuración de notificaciones.
Gestionada desde el frontend (sección ⚙️ Configuración).

```sql
CREATE TABLE configuracion (
    clave       TEXT PRIMARY KEY,
    valor       TEXT NOT NULL DEFAULT '',
    descripcion TEXT
);
```

Con valores iniciales incluidos en `schema.sql` vía `INSERT OR IGNORE`.
