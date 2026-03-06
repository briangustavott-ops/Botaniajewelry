# MCPs e integraciones

## Qué es un MCP

Los MCP (Model Context Protocol) son extensiones que amplían las capacidades de Claude Desktop, permitiéndole interactuar con sistemas externos: archivos, bases de datos, emails, APIs, etc.

En este proyecto, los MCPs permiten que la gestora interactúe con el sistema simplemente hablando con Claude, sin necesidad de abrir N8N o gestionar archivos manualmente.

---

## MCPs del proyecto

### Integrados por defecto en Claude Desktop

| MCP | Función en este proyecto |
|-----|--------------------------|
| **Filesystem** | Leer y escribir en la carpeta `media/` — guardar imágenes generadas, mover capturas entrantes, listar assets disponibles |
| **Fetch** | Consultar URLs de Etsy o Instagram para verificar que una publicación existe |

### A configurar

| MCP | Función en este proyecto | Prioridad |
|-----|--------------------------|-----------|
| **SQLite** | Claude consulta y actualiza la BD de assets directamente desde el chat ("¿qué fotos de pendientes quedan sin publicar?") | Alta |
| **Email (Gmail / Outlook)** | Leer emails con capturas de Etsy y Stories, extraer adjuntos y guardarlos automáticamente en `media/capturas/` | Alta |
| **N8N webhook** | La gestora dispara workflows desde el chat ("publica esta foto ahora en Instagram") | Media |

---

## Generación de imágenes con IA externa

Claude no genera imágenes de forma nativa. Se integra con servicios externos llamados desde N8N.

### Comparativa de servicios

| Servicio | Calidad para joyería | Coste aprox. | Integración |
|----------|---------------------|--------------|-------------|
| **Flux** (via Replicate) | Muy alta — fotorrealista | ~€0.003/imagen | HTTP node N8N |
| **Stability AI** | Alta | Pay-as-you-go | HTTP node N8N |
| **DALL-E 3** (OpenAI) | Alta | ~€0.04/imagen | HTTP node N8N |
| **Ideogram** | Buena para texto en imagen | Freemium | HTTP node N8N |

> Recomendación inicial: **Flux via Replicate** por calidad fotorrealista y precio bajo.

### Flujo: gestora solicita imagen desde el chat

```
Gestora en Claude Desktop:
"Genera una foto de pendientes de resina con flores azules, fondo blanco neutro"
        │
        ▼
Claude (MCP Filesystem + N8N webhook):
    → Construye el prompt optimizado para el modelo
    → Llama al webhook de N8N con el prompt
        │
        ▼
N8N workflow "generar-imagen":
    → Llama a Flux/DALL-E API
    → Recibe imagen
    → Guarda en media/generadas/[nombre].jpg
    → Registra en SQLite: tipo=foto, estado=disponible, origen=generada
        │
        ▼
Claude confirma a la gestora:
"Imagen guardada: media/generadas/pendientes_flores-azules_001.jpg
 Lista para publicar. ¿La programamos para Instagram?"
```

---

## Captura de comentarios y testimonios

### Caso de uso
La gestora hace capturas de pantalla de comentarios positivos en Etsy o de historias con menciones en Instagram, para usarlos como contenido social (prueba social, testimonios).

### Flujo via email

```
Gestora hace captura de pantalla
    │
    ▼
Envía al email del negocio con asunto: [CAPTURA] comentario etsy
    │
    ▼
N8N monitoriza el buzón (nodo Gmail/IMAP)
    → Detecta emails con asunto [CAPTURA]
    → Extrae imagen adjunta
    → Guarda en media/capturas/
    → Registra en SQLite con tipo=captura, origen=email
    │
    ▼
Asset disponible para próxima publicación
```

### Flujo via carpeta compartida (alternativo, más simple)
La gestora arrastra la captura directamente a `media/capturas/` en Windows.
N8N detecta el nuevo archivo (nodo File Watcher) y lo registra automáticamente.

---

## Arquitectura ampliada con MCPs

```
Claude Desktop (PC Windows)
├── MCP Filesystem   ──► media/ (leer/escribir assets)
├── MCP SQLite       ──► assets.db (consultar/actualizar catálogo)
├── MCP Email        ──► buzón de correo (leer capturas entrantes)
└── MCP Fetch        ──► verificar publicaciones en Instagram/Etsy

        │ webhook
        ▼
N8N (VM Ubuntu)
├── Workflow: publicar-instagram
├── Workflow: publicar-etsy
├── Workflow: publicar-web
├── Workflow: generar-imagen    ──► Flux / DALL-E API
├── Workflow: procesar-email    ──► media/capturas/
└── Workflow: file-watcher      ──► detectar nuevos assets
```

---

## Interacciones posibles desde el chat (ejemplos)

Una vez configurados los MCPs, la gestora puede:

| Lo que dice | Lo que ocurre |
|-------------|---------------|
| "¿Qué fotos de anillos tengo disponibles?" | Claude consulta SQLite y lista los assets |
| "Publica la foto de los pendientes azules en Instagram" | Claude dispara webhook → N8N publica |
| "Genera una imagen de un colgante con margaritas" | Claude llama webhook → N8N → Flux → guarda en media/ |
| "¿Qué publiqué la semana pasada?" | Claude consulta historial en SQLite |
| "Revisa si llegaron capturas de Etsy al correo" | Claude lee el buzón via MCP Email |
