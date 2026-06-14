#!/bin/bash

# Colores para la interfaz de la terminal
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}          kaliwebui - Inicializador Interactivo        ${NC}"
echo -e "${CYAN}======================================================${NC}"

# 1. Levantar servicios si no están activos
echo -e "\n${YELLOW}[+] Comprobando el estado de los contenedores...${NC}"
docker compose up -d

# 2. Esperar a que Ollama esté listo
echo -e "${YELLOW}[+] Esperando respuesta del servidor Ollama...${NC}"
until docker exec -it ollama_server ollama list > /dev/null 2>&1; do
    echo -n "."
    sleep 1.5
done
echo -e "\n${GREEN}[✓] ¡Ollama está respondiendo correctamente!${NC}"

# 3. Mostrar modelos ya instalados localmente
echo -e "\n${CYAN}[i] Modelos actualmente disponibles en tu sistema:${NC}"
echo -e "------------------------------------------------------"
docker exec -it ollama_server ollama list | awk 'NR>1 {print "  - " $1}'
echo -e "------------------------------------------------------"

# 4. Menú interactivo de selección de modelos
echo -e "\n${YELLOW}Selecciona una opción para descargar un modelo:${NC}"
echo -e "1) ${GREEN}qwen2.5-coder:7b${NC}   (Recomendado: Excelente en código y scripts)"
echo -e "2) ${GREEN}qwen2.5-coder:1.5b${NC} (Ligero: Muy rápido, bajo consumo de VRAM)"
echo -e "3) ${GREEN}llama3.1:8b${NC}        (Generalista: Potente y equilibrado)"
echo -e "4) ${GREEN}codellama:7b${NC}       (Especializado: Generación de código de Meta)"
echo -e "5) [Escribir otro modelo manualmente]"
echo -e "6) Salir / Mantener modelos actuales"

read -p "Introduce el número de tu opción: " OPCION

MODELO=""

case $OPCION in
    1)
        MODELO="qwen2.5-coder:7b"
        ;;
    2)
        MODELO="qwen2.5-coder:1.5b"
        ;;
    3)
        MODELO="llama3.1:8b"
        ;;
    4)
        MODELO="codellama:7b"
        ;;
    5)
        echo -e "\n${CYAN}Puedes buscar nombres de modelos en: https://ollama.com/library${NC}"
        read -p "Introduce el nombre exacto del modelo (ej. gemma2:2b): " MODELO_MANUAL
        MODELO=$MODELO_MANUAL
        ;;
    *)
        echo -e "\n${YELLOW}[!] Saltando descarga. Iniciando entorno...${NC}"
        ;;
esac

# 5. Ejecutar la descarga si se seleccionó un modelo
if [ ! -z "$MODELO" ]; then
    echo -e "\n${YELLOW}[+] Solicitando la descarga de ${GREEN}$MODELO${YELLOW} en Ollama...${NC}"
    echo -e "${CYAN}(Esto puede tardar unos minutos dependiendo de tu conexión a internet)${NC}\n"
    
    # Ejecuta ollama pull mostrando la barra de progreso nativa en la terminal
    docker exec -it ollama_server ollama pull $MODELO
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}[✓] ¡Modelo $MODELO descargado con éxito!${NC}"
    else
        echo -e "\n${RED}[-][Error] No se pudo descargar el modelo. Verifica el nombre o tu conexión.${NC}"
    fi
fi

# 6. Resumen final de accesos
echo -e "\n${CYAN}======================================================${NC}"
echo -e "${GREEN}     ¡ENTORNO KALIWEBUI COMPLETAMENTE CONFIGURADO!    ${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e " 🌐 Open WebUI:   ${GREEN}http://localhost:3000${NC}"
echo -e " 🐉 Consola Kali:  ${GREEN}docker exec -it kali_workspace /bin/bash${NC}"
echo -e "${CYAN}======================================================${NC}\n"