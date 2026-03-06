# Botania Jewelry — Automatización de contenido con IA

Proyecto de automatización de publicación de contenido para el negocio de joyería artesanal **Botania Jewelry**, haciendo uso de inteligencia artificial y orquestación con N8N.

## Idea general

Botania Jewelry vende joyería artesanal de resina (pendientes, anillos, colgantes con flores) a través de tres escaparates:

- **Instagram** — red social principal
- **Web propia** — tienda online
- **Etsy** — marketplace de terceros

El objetivo es que la IA seleccione y publique contenido de forma periódica y autónoma en cada plataforma, mientras la gestora del negocio se ocupa de otras tareas.

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Visión del proyecto](docs/01-vision.md) | Objetivos, alcance y casos de uso |
| [Arquitectura](docs/02-arquitectura.md) | Diseño técnico del sistema |
| [Stack tecnológico](docs/03-stack.md) | Herramientas y tecnologías utilizadas |
| [Fases del proyecto](docs/04-fases.md) | Hoja de ruta e hitos |
| [Biblioteca de contenido](docs/05-biblioteca-contenido.md) | Estructura del repositorio multimedia |

## Estado actual

> Fase 0 — Definición y documentación inicial

## Estructura del repositorio

```
Botaniajewelry/
├── docs/                   # Documentación del proyecto
├── media/                  # Biblioteca de contenido multimedia (local, no versionado)
├── workflows/              # Workflows de N8N exportados
├── prompts/                # Prompts de IA por plataforma
└── .env.example            # Variables de entorno (plantilla)
```
