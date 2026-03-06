# Frontend — Panel de control

Interfaz web centralizada para que la gestora administre todo el sistema desde un único lugar.
Accesible desde el navegador en `http://localhost:3000` mientras la VM corre en background.

## Tecnología

**FastAPI + HTML/JS** corriendo como contenedor Docker junto a N8N.
Sin instalaciones adicionales — todo incluido en la VM exportable.

---

## Secciones

### 📥 Bandeja de revisión

Muestra el contenido subido desde el móvil (Google Drive) con las sugerencias automáticas de la IA.
La gestora aprueba, edita o descarta cada asset antes de que entre en la cola de publicación.

![Bandeja de revisión](mockups/01-bandeja-revision.svg)

**Estados de los assets:**
| Estado | Significado |
|--------|-------------|
| 🟢 Disponible | Listo para publicar |
| 🟡 Pendiente de revisión | Subido desde móvil, sugerencias de IA listas para aprobar |
| 🔴 Error | La IA no pudo analizar el archivo — requiere revisión manual |
| 🔵 Publicado | Ya publicado en una o más plataformas |

---

### 📤 Subir contenido

Formulario para añadir contenido desde el PC con metadatos completos.
El botón **✨ Sugerir con IA** envía el archivo a Claude Vision y rellena automáticamente el texto, los hashtags y la categoría.

![Subir contenido](mockups/02-subir-contenido.svg)

---

### 📚 Biblioteca

Vista general de todos los assets con filtros por categoría, estado y plataforma.
Permite publicar directamente desde la biblioteca o ver el historial de un asset.

![Biblioteca de contenido](mockups/03-biblioteca.svg)

---

### 📱 Publicar

Selecciona un asset disponible, elige la plataforma de destino y revisa el caption generado por la IA antes de publicar.
Permite publicar ahora o programar para más tarde.

![Publicar contenido](mockups/04-publicar.svg)

**Lógica de plataforma:**
| Tipo de contenido | Destino sugerido por IA |
|-------------------|------------------------|
| Foto, fondo neutro, iluminación limpia | Instagram + Etsy |
| Foto lifestyle / ambiente | Instagram |
| Vídeo corto (< 60s) | Instagram Reel |
| Vídeo vertical (9:16) | Instagram Stories |
| Foto cuadrada producto solo | Etsy + Web |

---

### 📦 Productos Etsy

Crea nuevos listings en Etsy con ayuda de la IA.
Claude Vision analiza las fotos seleccionadas y genera el título, descripción y tags en inglés.
La gestora solo añade precio, stock y categoría antes de publicar.

![Nuevo producto en Etsy](mockups/05-etsy-producto.svg)

**Flujo:**
```
Seleccionar fotos de la biblioteca
    ↓
[✨ Generar listing con IA]  →  Claude genera: título · descripción · tags (EN)
    ↓
Gestora revisa y añade: precio · stock · categoría
    ↓
[Crear borrador en Etsy]  →  revisar en Etsy.com
    ↓
[Publicar en Etsy]
```

---

### ⚙️ Gestión de APIs

Estado de los tokens y claves API con indicadores visuales y alertas de expiración.

| Servicio | Estado | Acción |
|---------|--------|--------|
| Instagram (Meta) | 🟡 Expira en 12 días | Renovar token |
| Etsy API | 🟢 Activo | — |
| Claude API | 🟢 Activo | Ver uso del mes |
| Web CMS | 🔴 Sin configurar | Configurar |

---

## Estructura técnica

```
frontend/
├── main.py              # FastAPI — rutas y lógica
├── templates/
│   ├── base.html        # Layout común (sidebar + topbar)
│   ├── bandeja.html
│   ├── subir.html
│   ├── biblioteca.html
│   ├── publicar.html
│   ├── etsy.html
│   └── apis.html
├── static/
│   ├── style.css
│   └── app.js
└── Dockerfile
```
