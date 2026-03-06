#!/bin/bash
# ============================================================
# Botania Jewelry — Inicializar base de datos SQLite
# Uso: bash /ruta/al/repo/database/init.sh
# El script detecta su propia ubicación automáticamente.
# ============================================================

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/schema.sql"
DB_DIR="$HOME/botania/data/db"
DB_FILE="$DB_DIR/assets.db"

# Verificar que el schema existe
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ No se encontró el schema en: $SCHEMA_FILE"
    exit 1
fi

# Crear carpeta de la BD si no existe
mkdir -p "$DB_DIR"

# Advertir si la BD ya existe
if [ -f "$DB_FILE" ]; then
    echo "⚠️  La base de datos ya existe en $DB_FILE"
    read -p "¿Deseas recrearla? Esto borrará todos los datos. (s/N): " confirm
    if [ "$confirm" != "s" ]; then
        echo "Operación cancelada."
        exit 0
    fi
    rm "$DB_FILE"
fi

# Crear la base de datos aplicando el esquema
sqlite3 "$DB_FILE" < "$SCHEMA_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Base de datos creada en $DB_FILE"
    echo ""
    echo "Tablas:"
    sqlite3 "$DB_FILE" ".tables"
    echo ""
    echo "Vistas:"
    sqlite3 "$DB_FILE" "SELECT name FROM sqlite_master WHERE type='view';"
else
    echo "❌ Error al crear la base de datos."
    exit 1
fi
