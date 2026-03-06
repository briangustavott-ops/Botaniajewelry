# Fases del proyecto

## Hoja de ruta

```
Fase 0 ──► Fase 1 ──► Fase 2 ──► Fase 3 ──► Fase 4 ──► Fase 5 ──► Fase 6
 Setup     Drive+IA   Frontend  Instagram    Web        Etsy       Pulido
```

---

## Fase 0 — Infraestructura y definición ✅ Completada

**Objetivo:** tener el entorno listo y el proyecto documentado.

- [x] Crear repositorio en GitHub
- [x] Documentación inicial del proyecto
- [x] Mockups del frontend
- [x] Crear VM Ubuntu Server en VMware Workstation
- [x] Configurar red: NAT (internet) + Host-Only 192.168.137.10 (host↔VM)
- [x] Instalar Docker + Docker Compose en la VM (v29.3.0 / v5.1.0)
- [x] Levantar N8N en la VM (accesible en http://192.168.137.10:5678)
- [x] Crear base de datos SQLite con esquema inicial (assets + publicaciones, verificado desde N8N)
- [x] Configurar `.env` con variables de infraestructura (API keys pendientes de Fase 1)

---

## Fase 1 — Google Drive + análisis IA

**Objetivo:** el sistema detecta contenido nuevo en Google Drive y lo analiza automáticamente con IA.

- [ ] Configurar Google Drive API y credenciales OAuth
- [ ] Crear estructura de carpetas en Google Drive (`entrada/`, `instagram/`, `etsy/`, etc.)
- [ ] Crear workflow N8N: Watch Google Drive → descargar archivo → llamar a Claude Vision
- [ ] Claude Vision analiza imagen: tipo, colores, materiales, plataforma sugerida, caption ES+EN, hashtags
- [ ] Guardar resultado en SQLite con estado `pendiente_revision`
- [ ] Probar flujo completo: sube foto desde móvil → aparece en SQLite con sugerencias

---

## Fase 2 — Frontend (panel de control)

**Objetivo:** la gestora puede gestionar todo el sistema desde una interfaz web.

- [ ] Crear proyecto FastAPI con Docker
- [ ] Implementar sección: Bandeja de revisión (aprobar/editar/descartar assets)
- [ ] Implementar sección: Subir contenido (drag & drop + análisis IA)
- [ ] Implementar sección: Biblioteca (grid con filtros)
- [ ] Implementar sección: Gestión de APIs (estado de tokens)
- [ ] Integrar frontend con SQLite y N8N webhooks
- [ ] Validar con la gestora (UX y flujo)

---

## Fase 3 — Publicación en Instagram

**Objetivo:** primer workflow funcional de publicación automática en Instagram.

- [ ] Configurar cuenta Business en Instagram + página de Facebook
- [ ] Obtener y configurar token Meta Graph API (60 días)
- [ ] Crear workflow N8N: seleccionar asset disponible → generar caption → publicar en Instagram
- [ ] Implementar sección "Publicar" en el frontend (publicación manual)
- [ ] Configurar trigger de cron (publicación automática programada)
- [ ] Implementar renovación de token desde el panel ⚙️
- [ ] Validar con la gestora

---

## Fase 4 — Publicación en web propia

**Objetivo:** ampliar el workflow a la web de la gestora.

- [ ] Identificar CMS de la web (WordPress, Shopify, otro)
- [ ] Configurar API del CMS
- [ ] Crear workflow N8N para publicación web
- [ ] Adaptar prompts de IA para formato web (más largo, SEO)
- [ ] Añadir web como opción en la sección "Publicar" del frontend

---

## Fase 5 — Etsy (listings + publicación)

**Objetivo:** crear y publicar productos en Etsy desde el frontend.

- [ ] Registrar aplicación en Etsy Developers
- [ ] Configurar OAuth 2.0
- [ ] Implementar sección "Productos Etsy" en el frontend
- [ ] Integrar Claude Vision para generar listing completo en inglés
- [ ] Crear workflow N8N: crear draft en Etsy → publicar
- [ ] Añadir Etsy como destino en el workflow de publicación automática

---

## Fase 6 — MCPs, IA generativa y pulido final

**Objetivo:** ampliar capacidades con MCPs, generación de imágenes y preparar la entrega.

- [ ] Configurar MCP SQLite en Claude Desktop
- [ ] Configurar MCP Email para captura de comentarios Etsy y Stories
- [ ] Integrar API Flux (Replicate) para generación de imágenes bajo petición
- [ ] Crear workflow N8N `generar-imagen` disparado por webhook del frontend o Claude Desktop
- [ ] Optimizar consumo de recursos de la VM
- [ ] Crear sistema de notificaciones (email o Telegram)
- [ ] Documentar proceso de instalación para la usuaria
- [ ] Exportar VM como `.ova`
- [ ] Prueba de importación en PC de la usuaria con VMware Player
- [ ] Formación y entrega

---

## Criterios de éxito

- El sistema publica contenido de forma autónoma al menos 3 veces por semana en Instagram
- La gestora puede subir una foto desde el móvil y tenerla lista para publicar en menos de 2 minutos
- El frontend permite gestionar todo el sistema sin conocimientos técnicos
- La VM corre en background sin afectar al rendimiento del PC
- En caso de error, la gestora recibe una notificación clara
- El sistema es exportable e instalable en el PC de la usuaria en menos de 1 hora
