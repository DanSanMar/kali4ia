#!/bin/bash

set -e

export PATH="/home/kali/.local/bin:/usr/local/bin:$PATH"

echo "[setup] Verificando red con Ollama..."
TARGET_HOST="ollama"
MAX_RETRIES=15
COUNT=0

while ! getent hosts $TARGET_HOST > /dev/null; do
  COUNT=$((COUNT+1))
  if [ $COUNT -ge $MAX_RETRIES ]; then
    echo "❌ ERROR: No se puede encontrar el host '$TARGET_HOST'."
    exit 1
  fi
  sleep 2
done

CLEAN_URL="http://ollama:11434"
API_BASE="$CLEAN_URL/api"

# Inyectar PATH en bashrc de kali si no existe
if ! grep -q ".local/bin" /home/kali/.bashrc; then
    echo 'export PATH="/home/kali/.local/bin:$PATH"' >> /home/kali/.bashrc
fi

# Pre-descarga del modelo configurado
if curl -s "$API_BASE/tags" > /dev/null; then
    MODELO_ACTUAL="${DEFAULT_MODEL:-qwen2.5-coder:1.5b}"
    echo "[setup] Solicitando pull de: $MODELO_ACTUAL"
    curl -s -X POST "$API_BASE/pull" -H "Content-Type: application/json" -d "{\"name\": \"$MODELO_ACTUAL\"}"
fi

# Creación de estructuras limpias de trabajo
DIRECTORIOS=(
    "/home/kali/evidences"
    "/home/kali/scripts"
    "/home/kali/reports"
)

for dir in "${DIRECTORIOS[@]}"; do
    mkdir -p "$dir"
done

# Asegurar permisos correctos del volumen mapeado
chown -R kali:kali /home/kali


echo "------------------------------------------------"
echo "[setup] Iniciando Servidor Open Terminal en Kali Linux..."
echo "------------------------------------------------"

# Forzamos los parámetros directamente por comandos de CLI para evitar fallos de lectura
exec open-terminal run --host 0.0.0.0 --port 8000 --api-key "$OPEN_TERMINAL_API_KEY"