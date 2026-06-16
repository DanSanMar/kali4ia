# init_windows.ps1
Clear-Host
$CYAN = "`e[0;36m"
$GREEN = "`e[0;32m"
$YELLOW = "`e[1;33m"
$RED = "`e[0;31m"
$NC = "`e[0m"

Write-Host "${CYAN}======================================================${NC}"
Write-Host "${GREEN}       kaliwebui - Inicializador para Windows (PowerShell)${NC}"
Write-Host "${CYAN}======================================================${NC}"

# 1. Levantar servicios
Write-Host "`n${YELLOW}[+] Comprobando el estado de los contenedores...${NC}"
docker compose up -d

# 2. Esperar a Ollama
Write-Host "${YELLOW}[+] Esperando respuesta del servidor Ollama...${NC}"
while ($true) {
    $check = docker exec -i ollama_server ollama list 2>$null
    if ($LASTEXITCODE -eq 0) { break }
    Write-Host -NoNewline "."
    Start-Sleep -Seconds 1.5
}
Write-Host "`n${GREEN}[✓] ¡Ollama está respondiendo correctamente!${NC}"

# 3. Mostrar modelos actuales
Write-Host "`n${CYAN}[i] Modelos actualmente disponibles en tu sistema:${NC}"
Write-Host "------------------------------------------------------"
docker exec -i ollama_server ollama list | Select-Object -Skip 1 | ForEach-Object {
    $mod = $_.Split("{0}" -f [char]32)[0]
    if ($mod) { Write-Host "  - $mod" }
}
Write-Host "------------------------------------------------------"

# 4. Menú interactivo
Write-Host "`n${YELLOW}Selecciona una opción para descargar un modelo:${NC}"
Write-Host "1) ${GREEN}qwen2.5-coder:7b${NC}   (Recomendado)"
Write-Host "2) ${GREEN}qwen2.5-coder:1.5b${NC} (Ligero)"
Write-Host "3) ${GREEN}llama3.1:8b${NC}"
Write-Host "4) Salir / Mantener actuales"

$opcion = Read-Host "`nIntroduce el número de tu opción"

$modelo = ""
if ($opcion -eq "1") { $modelo = "qwen2.5-coder:7b" }
elseif ($opcion -eq "2") { $modelo = "qwen2.5-coder:1.5b" }
elseif ($opcion -eq "3") { $modelo = "llama3.1:8b" }

if ($modelo -ne "") {
    Write-Host "`n${YELLOW}[+] Descargando $modelo en Ollama...${NC}"
    docker exec -it ollama_server ollama pull $modelo
}

# Resumen final
Write-Host "`n${CYAN}======================================================${NC}"
Write-Host "${GREEN}     ¡ENTORNO KALIWEBUI CONFIGURADO EN WINDOWS!       ${NC}"
Write-Host "${CYAN}======================================================${NC}"
Write-Host " 🌐 Open WebUI:   http://localhost:3000"
Write-Host " 🐉 Consola Kali:  docker exec -it kali_workspace /bin/bash"
Write-Host "${CYAN}======================================================${NC}`n"