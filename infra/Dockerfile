# ============================================================
# Botania Jewelry — Imagen N8N personalizada
# Multi-stage build para compilar módulos nativos de Node.js
#
# Problema: n8nio/n8n usa Docker Hardened Images (DHI) —
# Alpine sin gestor de paquetes (ni apk ni apt-get).
# Solución: compilar sqlite3 en una imagen Alpine completa
# y copiar el resultado a la imagen de N8N.
# ============================================================

# ── Stage 1: Compilar sqlite3 nativo para Node.js v24 ────────
# node:24-alpine tiene apk y todas las herramientas necesarias
FROM node:24-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /build
RUN npm install n8n-nodes-sqlite

# ── Stage 2: Imagen N8N con el nodo precompilado ─────────────
FROM n8nio/n8n:latest

USER root

# Copiar los módulos compilados a /n8n-custom-nodes
# Este directorio NO está cubierto por el volumen ./data/n8n
# por lo que los archivos del build siempre están disponibles
RUN mkdir -p /n8n-custom-nodes/node_modules

COPY --from=builder /build/node_modules /n8n-custom-nodes/node_modules

USER node
