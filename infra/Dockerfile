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
# Nota: n8nio/n8n usa Debian (no Alpine) → apt-get en lugar de apk
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 make g++ && \
    rm -rf /var/lib/apt/lists/*

USER node
