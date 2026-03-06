-- ============================================================
-- Botania Jewelry — Esquema de base de datos SQLite
-- ============================================================

PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

-- ============================================================
-- TABLA: assets
-- Catálogo de todo el contenido multimedia del sistema
-- ============================================================
CREATE TABLE IF NOT EXISTS assets (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Archivo
    archivo             TEXT NOT NULL,          -- Ruta relativa en la VM: media/fotos/pendientes/...
    nombre_original     TEXT,                   -- Nombre original del archivo subido

    -- Clasificación
    tipo                TEXT NOT NULL           -- foto | video | reel | historia | captura | generada
                        CHECK(tipo IN ('foto','video','reel','historia','captura','generada')),
    categoria           TEXT                    -- pendientes | anillos | colgantes
                        CHECK(categoria IN ('pendientes','anillos','colgantes', NULL)),
    origen              TEXT NOT NULL           -- drive_movil | frontend_pc | ia_generada | email_captura
                        CHECK(origen IN ('drive_movil','frontend_pc','ia_generada','email_captura')),

    -- Metadatos del producto
    descripcion         TEXT,                   -- Descripción libre del producto
    colores             TEXT,                   -- Colores detectados por IA o indicados manualmente
    materiales          TEXT,                   -- Materiales (resina, flores, metal...)

    -- Contenido generado por IA
    caption_es          TEXT,                   -- Caption en español
    caption_en          TEXT,                   -- Caption en inglés
    hashtags            TEXT,                   -- Hashtags separados por espacios

    -- Destino y configuración
    plataformas_destino TEXT,                   -- instagram,etsy,web (separadas por coma)
    idiomas             TEXT DEFAULT 'es'       -- es | en | es,en
                        CHECK(idiomas IN ('es','en','es,en')),

    -- Estado en el ciclo de vida
    estado              TEXT NOT NULL DEFAULT 'subido'
                        CHECK(estado IN (
                            'subido',             -- Recién llegado al sistema
                            'analizando',         -- Claude Vision procesando
                            'pendiente_revision', -- Sugerencias listas, esperando aprobación
                            'error_analisis',     -- No se pudo analizar (baja res, formato, etc.)
                            'disponible',         -- Aprobado, listo para publicar
                            'programado',         -- En cola de publicación
                            'publicado',          -- Publicado en al menos una plataforma
                            'descartado'          -- Revisado y descartado por la gestora
                        )),
    error_detalle       TEXT,                   -- Descripción del error si estado = error_analisis

    -- Fechas
    fecha_subida        DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_aprobacion    DATETIME
);

-- Índices para consultas frecuentes de N8N
CREATE INDEX IF NOT EXISTS idx_assets_estado       ON assets(estado);
CREATE INDEX IF NOT EXISTS idx_assets_tipo         ON assets(tipo);
CREATE INDEX IF NOT EXISTS idx_assets_categoria    ON assets(categoria);
CREATE INDEX IF NOT EXISTS idx_assets_fecha_subida ON assets(fecha_subida);


-- ============================================================
-- TABLA: publicaciones
-- Historial de cada vez que un asset se publica en una plataforma
-- ============================================================
CREATE TABLE IF NOT EXISTS publicaciones (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,

    asset_id            INTEGER NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    plataforma          TEXT NOT NULL
                        CHECK(plataforma IN ('instagram','web','etsy')),

    -- Resultado
    fecha               DATETIME DEFAULT CURRENT_TIMESTAMP,
    url_publicacion     TEXT,                   -- URL del post publicado
    caption_usado       TEXT,                   -- Texto final publicado
    estado              TEXT NOT NULL DEFAULT 'ok'
                        CHECK(estado IN ('ok','error')),
    error_detalle       TEXT
);

CREATE INDEX IF NOT EXISTS idx_pub_asset_id   ON publicaciones(asset_id);
CREATE INDEX IF NOT EXISTS idx_pub_plataforma ON publicaciones(plataforma);
CREATE INDEX IF NOT EXISTS idx_pub_fecha      ON publicaciones(fecha);


-- ============================================================
-- TABLA: configuracion
-- Parámetros del sistema gestionados desde el frontend
-- Programación de publicación automática y notificaciones
-- ============================================================
CREATE TABLE IF NOT EXISTS configuracion (
    clave       TEXT PRIMARY KEY,
    valor       TEXT NOT NULL DEFAULT '',
    descripcion TEXT
);

-- Valores por defecto (INSERT OR IGNORE: no sobreescribe si ya existen)

-- Programación Instagram
INSERT OR IGNORE INTO configuracion VALUES
    ('instagram_activo',       '1',     'Publicación automática en Instagram activa (1/0)'),
    ('instagram_posts_semana', '3',     'Máximo de publicaciones automáticas por semana'),
    ('instagram_horario',      '10:00', 'Hora preferida de publicación (HH:MM, zona Europe/Madrid)'),
    ('instagram_dias',         '1,3,5', 'Días de la semana (1=lun, 2=mar … 7=dom)');

-- Programación Web
INSERT OR IGNORE INTO configuracion VALUES
    ('web_activo',             '1',     'Publicación automática en web activa (1/0)'),
    ('web_posts_semana',       '2',     'Máximo de publicaciones automáticas por semana'),
    ('web_horario',            '11:00', 'Hora preferida de publicación (HH:MM, zona Europe/Madrid)'),
    ('web_dias',               '2,4',   'Días de la semana (1=lun, 2=mar … 7=dom)');

-- Notificaciones Telegram
INSERT OR IGNORE INTO configuracion VALUES
    ('notif_telegram_token',   '', 'Bot token de Telegram (vacío = Telegram desactivado)'),
    ('notif_telegram_chat_id', '', 'Chat ID del destinatario Telegram');

-- Notificaciones Email (alternativa a Telegram)
INSERT OR IGNORE INTO configuracion VALUES
    ('notif_email',            '', 'Dirección de email destino (vacío = email desactivado)'),
    ('notif_email_smtp_host',  '', 'Servidor SMTP'),
    ('notif_email_smtp_user',  '', 'Usuario SMTP'),
    ('notif_email_smtp_pass',  '', 'Contraseña SMTP');


-- ============================================================
-- VISTA: assets_disponibles
-- Assets listos para publicar (uso frecuente en W3 auto-publisher)
-- ============================================================
CREATE VIEW IF NOT EXISTS assets_disponibles AS
SELECT
    a.*,
    (SELECT MAX(p.fecha)
     FROM publicaciones p
     WHERE p.asset_id = a.id) AS ultima_publicacion
FROM assets a
WHERE a.estado = 'disponible';


-- ============================================================
-- VISTA: bandeja_revision
-- Assets pendientes de revisión (para el frontend — W4)
-- ============================================================
CREATE VIEW IF NOT EXISTS bandeja_revision AS
SELECT *
FROM assets
WHERE estado IN ('pendiente_revision', 'error_analisis')
ORDER BY fecha_subida DESC;


-- ============================================================
-- VISTA: publicaciones_semana
-- Conteo de publicaciones exitosas por plataforma en la semana actual
-- Usada por W3 para decidir si toca publicar
-- ============================================================
CREATE VIEW IF NOT EXISTS publicaciones_semana AS
SELECT
    plataforma,
    COUNT(*) AS total
FROM publicaciones
WHERE estado = 'ok'
  AND strftime('%Y-%W', fecha) = strftime('%Y-%W', 'now')
GROUP BY plataforma;
