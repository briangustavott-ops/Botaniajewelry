#!/bin/bash
# ============================================================
# Botania Jewelry — Inicializar base de datos SQLite
# Ejecutar desde la VM: bash ~/botania/database/init.sh
# ============================================================

DB_DIR="$HOME/botania/data/db"
DB_FILE="$DB_DIR/assets.db"
SCHEMA_FILE="$HOME/botania/database/schema.sql"

# Crear carpeta si no existe
mkdir -p "$DB_DIR"

# Crear la base de datos aplicando el esquema
if [ -f "$DB_FILE" ]; then
    echo "⚠️  La base de datos ya existe en $DB_FILE"
    read -p "¿Deseas recrearla? Esto borrará todos los datos. (s/N): " confirm
    if [ "$confirm" != "s" ]; then
        echo "Operación cancelada."
        exit 0
    fi
    rm "$DB_FILE"
fi

sqlite3 "$DB_FILE" < "$SCHEMA_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Base de datos creada en $DB_FILE"
    echo ""
    echo "Tablas creadas:"
    sqlite3 "$DB_FILE" ".tables"
    echo ""
    echo "Vistas creadas:"
    sqlite3 "$DB_FILE" "SELECT name FROM sqlite_master WHERE type='view';"
else
    echo "❌ Error al crear la base de datos."
    exit 1
fi
