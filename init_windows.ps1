# init_windows.ps1
Clear-Host

# Mostrar encabezado
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "       kaliwebui - Inicializador para Windows" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

# 1. Levantar servicios
Write-Host ""
Write-Host "[+] Comprobando el estado de los contenedores..." -ForegroundColor Yellow
docker compose up -d

# 2. Esperar a Ollama
Write-Host "[+] Esperando respuesta del servidor Ollama..." -ForegroundColor Yellow
while ($true) {
    $null = docker exec -i ollama_server ollama list 2>$null
    if ($LASTEXITCODE -eq 0) { break }
    Write-Host -NoNewline "."
    Start-Sleep -Seconds 2
}
Write-Host ""
Write-Host "[OK] Ollama esta respondiendo correctamente!" -ForegroundColor Green

# 3. Mostrar modelos actuales
Write-Host ""
Write-Host "[i] Modelos actualmente disponibles en tu sistema:" -ForegroundColor Cyan
Write-Host "------------------------------------------------------"
docker exec -i ollama_server ollama list | Select-Object -Skip 1 | ForEach-Object {
    $parts = $_ -split '\s+'
    $mod = $parts[0]
    if ($mod) { Write-Host "  - $mod" }
}
Write-Host "------------------------------------------------------"

# 4. Menu interactivo
Write-Host ""
Write-Host "Selecciona una opcion para descargar un modelo:" -ForegroundColor Yellow
Write-Host "1) qwen2.5-coder:7b   (Recomendado)" -ForegroundColor Green
Write-Host "2) qwen2.5-coder:1.5b (Ligero)" -ForegroundColor Green
Write-Host "3) llama3.1:8b" -ForegroundColor Green
Write-Host "4) Salir / Mantener actuales"

$opcion = Read-Host "Introduce el numero de tu opcion"

$modelo = ""
if ($opcion -eq "1") { $modelo = "qwen2.5-coder:7b" }
elseif ($opcion -eq "2") { $modelo = "qwen2.5-coder:1.5b" }
elseif ($opcion -eq "3") { $modelo = "llama3.1:8b" }

if ($modelo -ne "") {
    Write-Host ""
    Write-Host "[+] Descargando $modelo en Ollama..." -ForegroundColor Yellow
    docker exec -it ollama_server ollama pull $modelo
}

# Resumen final
Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "     ENTORNO KALIWEBUI CONFIGURADO EN WINDOWS         " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Open WebUI:   http://localhost:3000"
Write-Host " Consola Kali:  docker exec -it kali_workspace /bin/bash"
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""