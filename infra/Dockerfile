# ============================================================
# Botania Jewelry — Imagen N8N personalizada
# Extiende n8nio/n8n añadiendo herramientas de compilación
# necesarias para nodos de comunidad con módulos nativos
# (sqlite3, canvas, sharp, etc.)
# ============================================================
FROM n8nio/n8n:latest

USER root

# Herramientas de compilación para módulos nativos de Node.js
# python3 + make + g++ son necesarios para compilar sqlite3
RUN apk add --no-cache python3 make g++

USER node
