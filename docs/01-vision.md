# Visión del proyecto

## Contexto

**Botania Jewelry** es un negocio de joyería artesanal. Sus productos son piezas de resina (pendientes, anillos, colgantes) con elementos naturales como flores, plantas y otros elementos encapsulados en formas como esferas, gotas y geometrías.

El negocio lo gestiona **una sola persona**, que compagina la producción artesanal con la gestión de redes sociales, tienda y comunicación.

## Problema

La gestión manual de contenido en múltiples plataformas consume tiempo que podría dedicarse a la producción. Mantener una presencia constante y de calidad en Instagram, web y Etsy requiere:

- Seleccionar fotos o vídeos
- Redactar textos adaptados a cada plataforma
- Añadir hashtags, descripciones, alt-text
- Publicar en el momento adecuado
- Repetir el proceso periódicamente

## Objetivo

Automatizar el ciclo completo de publicación de contenido usando IA, de forma que:

- La IA **seleccione** qué contenido publicar
- La IA **genere** los textos adaptados a cada plataforma e idioma
- N8N **orqueste** el proceso y lo ejecute de forma programada
- La gestora solo intervenga para añadir nuevo contenido a la biblioteca

## Escaparates

| Plataforma | Tipo de publicación | API disponible |
|------------|-------------------|----------------|
| Instagram | Posts, Reels, Stories | Meta Graph API |
| Web propia | Entradas, banners, producto | CMS API (por definir) |
| Etsy | Listings, fotos, descripciones | Etsy API v3 |

## Casos de uso principales

1. **Publicación programada:** cada X días, publicar una foto o vídeo en Instagram con caption y hashtags generados por IA
2. **Actualización de Etsy:** rotar fotos destacadas de listings o actualizar descripciones según temporada
3. **Contenido web:** generar entradas de blog o actualizaciones de producto de forma periódica
4. **Multi-idioma:** publicar en español e inglés según plataforma

## Fuera de alcance (por ahora)

- Respuesta automática a comentarios o mensajes
- Creación de nuevos listings en Etsy desde cero
- Edición automática de fotos o vídeos
- Analítica de rendimiento
