# Fases del proyecto

## Hoja de ruta

```
Fase 0 ──► Fase 1 ──► Fase 2 ──► Fase 3 ──► Fase 4 ──► Fase 5
 Setup      Instagram   Web        Etsy       MCPs       Pulido
```

---

## Fase 0 — Infraestructura y definición ✅ En curso

**Objetivo:** tener el entorno listo y el proyecto documentado.

- [x] Crear repositorio en GitHub
- [x] Documentación inicial del proyecto
- [ ] Crear VM Ubuntu Server en VMware Workstation
- [ ] Instalar Docker + Docker Compose en la VM
- [ ] Levantar N8N en la VM
- [ ] Configurar carpeta compartida (Windows ↔ VM)
- [ ] Crear estructura de carpetas de la biblioteca de contenido
- [ ] Crear base de datos SQLite con esquema inicial
- [ ] Configurar `.env` con claves API

---

## Fase 1 — Publicación en Instagram

**Objetivo:** primer workflow funcional que publique en Instagram.

- [ ] Configurar cuenta Business en Instagram
- [ ] Obtener token Meta Graph API
- [ ] Crear workflow N8N: seleccionar foto → generar caption con Claude → publicar en Instagram
- [ ] Probar publicación manual desde N8N
- [ ] Configurar trigger de cron (publicación automática)
- [ ] Validar con la usuaria

---

## Fase 2 — Publicación en web propia

**Objetivo:** ampliar el workflow a la web de la usuaria.

- [ ] Identificar CMS de la web (WordPress, Shopify, otro)
- [ ] Configurar API del CMS
- [ ] Crear workflow N8N para publicación web
- [ ] Adaptar prompts de IA para formato web
- [ ] Integrar con el workflow principal

---

## Fase 3 — Publicación en Etsy

**Objetivo:** automatizar actualizaciones de listings en Etsy.

- [ ] Registrar aplicación en Etsy Developers
- [ ] Configurar OAuth 2.0
- [ ] Crear workflow para actualización de fotos y descripciones
- [ ] Definir qué se automatiza (fotos, descripciones, temporadas)

---

## Fase 4 — Pulido y exportación

**Objetivo:** preparar el sistema para la usuaria final.

- [ ] Optimizar consumo de recursos de la VM
- [ ] Crear panel de control simple (o Telegram bot) para monitorización
- [ ] Documentar proceso de instalación para la usuaria
- [ ] Exportar VM como `.ova`
- [ ] Prueba de importación en PC de la usuaria
- [ ] Formación y entrega

---

## Fase 4 — MCPs e IA generativa

**Objetivo:** ampliar las capacidades del sistema con MCPs y generación de imágenes.

- [ ] Configurar MCP SQLite en Claude Desktop
- [ ] Configurar MCP Email (Gmail/Outlook) para captura de comentarios Etsy y Stories
- [ ] Crear workflow N8N "file-watcher" para detectar nuevos assets automáticamente
- [ ] Integrar API de generación de imágenes (Flux via Replicate o DALL-E)
- [ ] Crear workflow N8N "generar-imagen" disparado por webhook
- [ ] Probar flujo completo: chat → imagen generada → guardada en media/ → publicada

---

## Fase 5 — Pulido y exportación

**Objetivo:** preparar el sistema para la usuaria final.

- [ ] Optimizar consumo de recursos de la VM
- [ ] Crear sistema de notificaciones (Telegram bot o email)
- [ ] Documentar proceso de instalación para la usuaria
- [ ] Exportar VM como `.ova`
- [ ] Prueba de importación en PC de la usuaria con VMware Player
- [ ] Formación y entrega

---

## Criterios de éxito

- El sistema publica contenido de forma autónoma al menos 3 veces por semana en Instagram
- La gestora solo necesita añadir nuevas fotos a la carpeta de medios
- El sistema corre en background sin afectar al rendimiento del PC
- En caso de error, la gestora recibe una notificación
