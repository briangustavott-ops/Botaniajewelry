# Visión del proyecto

## Contexto

**Botania Jewelry** es un negocio de joyería artesanal. Sus productos son piezas de resina (pendientes, anillos, colgantes) con elementos naturales como flores, plantas y otros elementos encapsulados en formas como esferas, gotas y geometrías.

El negocio lo gestiona **una sola persona**, que compagina la producción artesanal con la gestión de redes sociales, tienda y comunicación.

## Problema

La gestión manual de contenido en múltiples plataformas consume tiempo que podría dedicarse a la producción. Mantener una presencia constante y de calidad en Instagram, web y Etsy requiere:

- Fotografiar y seleccionar las mejores tomas del producto
- Redactar textos adaptados a cada plataforma e idioma
- Añadir hashtags, descripciones, alt-text
- Crear listings en Etsy con título, descripción y tags en inglés
- Publicar en el momento adecuado y de forma constante

## Objetivo

Automatizar el ciclo completo de publicación de contenido usando IA, de forma que:

- La gestora **suba contenido** desde el móvil o el PC con el mínimo esfuerzo
- La IA **analice, clasifique y genere textos** adaptados a cada plataforma
- La gestora **revise y apruebe** las sugerencias desde un panel centralizado
- N8N **orqueste y ejecute** las publicaciones de forma programada y autónoma
- La IA pueda **generar imágenes** de producto bajo petición de la gestora

## Escaparates

| Plataforma | Tipo de publicación | API disponible |
|------------|-------------------|----------------|
| Instagram | Posts, Reels, Stories | Meta Graph API |
| Web propia | Entradas, banners, producto | CMS API (por definir) |
| Etsy | Listings completos, fotos, descripciones | Etsy API v3 |

## Casos de uso principales

1. **Subida desde móvil:** la gestora fotografía una pieza y la sube a Google Drive; la IA la analiza automáticamente y prepara el contenido listo para aprobar
2. **Publicación programada:** cada X días, N8N publica un asset aprobado en Instagram con caption y hashtags generados por IA
3. **Nuevo producto en Etsy:** desde el panel de control, la gestora selecciona fotos y la IA genera el listing completo en inglés (título, descripción, tags)
4. **Generación de imágenes:** la gestora solicita a la IA una imagen de un producto vía chat o frontend; la IA la genera y la añade a la biblioteca
5. **Captura de testimonios:** la gestora envía por email capturas de comentarios de Etsy o menciones en Stories; el sistema las guarda como assets para publicar como prueba social
6. **Multi-idioma:** publicar en español e inglés según la plataforma (ES para Instagram, EN para Etsy)

## Panel de control (frontend)

La gestora dispone de una interfaz web centralizada accesible en `http://localhost:3000`:

| Sección | Función |
|---------|---------|
| 📥 Bandeja de revisión | Revisar y aprobar contenido subido desde el móvil con sugerencias de IA |
| 📤 Subir contenido | Añadir fotos/vídeos desde el PC con asistencia de IA |
| 📚 Biblioteca | Ver todos los assets, su estado e historial de publicaciones |
| 📱 Publicar | Publicar o programar contenido en cualquier plataforma |
| 📦 Productos Etsy | Crear nuevos listings con texto generado por IA |
| ⚙️ Gestión de APIs | Estado y renovación de tokens y claves |

## Fuera de alcance (por ahora)

- Respuesta automática a comentarios o mensajes directos
- Edición automática de fotos o vídeos (recorte, filtros, etc.)
- Analítica de rendimiento de publicaciones
- Gestión de pedidos o atención al cliente
