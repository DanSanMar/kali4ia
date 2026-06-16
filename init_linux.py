#!/usr/bin/env python3
import os
import sys
import subprocess
import time


GREEN = "\033[0;32m"
CYAN = "\033[0;36m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"

def clear_screen():
    os.system('clear' if os.name == 'posix' else 'cls')

def run_command(command, shell=True, capture_output=False):
    """Ejecuta un comando del sistema de forma segura."""
    try:
        result = subprocess.run(command, shell=shell, check=True, 
                                capture_output=capture_output, text=True)
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr

def check_pre_requisites():
    """Verifica que Docker esté instalado y el usuario tenga permisos."""
    print(f"{YELLOW}[+] Verificando requisitos del sistema...{NC}")
    
    # 1. ¿Existe docker?
    success, _ = run_command("docker --version", capture_output=True)
    if not success:
        print(f"{RED}[-][Error] Docker no está instalado en este sistema.{NC}")
        print(f"{CYAN}Sugerencia: Ejecuta los comandos de instalación de Docker oficiales para tu distribución.{NC}")
        sys.exit(1)
        
    # 2. ¿Tiene permisos sin sudo?
    success, _ = run_command("docker ps", capture_output=True)
    if not success:
        print(f"{RED}[-][Error] Tu usuario no tiene permisos para usar Docker sin 'sudo'.{NC}")
        print(f"{CYAN}Sugerencia: Ejecuta: 'sudo usermod -aG docker $USER' y reinicia sesión.{NC}")
        sys.exit(1)

    # 3. ¿Hay GPU NVIDIA configurada en Docker?
    _, stdout = run_command("docker info | grep -i nvidia", capture_output=True)
    if "nvidia" in stdout.lower():
        print(f"{GREEN}[✓] NVIDIA Container Toolkit detectado. Soporte GPU activo.{NC}")
    else:
        print(f"{YELLOW}[!] No se detectó el runtime de NVIDIA en Docker. Se usará modo CPU.{NC}")

def start_containers():
    """Levanta el entorno con docker-compose."""
    print(f"\n{YELLOW}[+] Levantando los contenedores de KaliWebUI...{NC}")
    success, _ = run_command("docker compose up -d")
    if not success:
        print(f"{RED}[-][Error] Falló 'docker compose up -d'. Revisa tu docker-compose.yml.{NC}")
        sys.exit(1)

def wait_for_ollama():
    """Espera de forma nativa a que el servidor de Ollama responda."""
    print(f"{YELLOW}[+] Esperando respuesta del servidor Ollama...{NC}")
    retries = 0
    while retries < 20:
        success, _ = run_command("docker exec -it ollama_server ollama list", capture_output=True)
        if success:
            print(f"{GREEN}[✓] ¡Ollama está respondiendo correctamente!{NC}\n")
            return
        print(".", end="", flush=True)
        time.sleep(1.5)
        retries += 1
    
    print(f"\n{RED}[-][Error] El servidor Ollama tardó demasiado en responder.{NC}")
    sys.exit(1)

def show_available_models():
    """Muestra los modelos que el usuario ya tiene descargados."""
    print(f"{CYAN}[i] Modelos actualmente disponibles en tu sistema:{NC}")
    print("------------------------------------------------------")
    # Ejecutamos 'ollama list' y formateamos la salida de forma limpia en Python
    success, stdout = run_command("docker exec -it ollama_server ollama list", capture_output=True)
    if success:
        lines = stdout.strip().split('\n')
        for line in lines[1:]: # Saltamos la cabecera
            if line:
                model_name = line.split()[0]
                print(f"  - {model_name}")
    print("------------------------------------------------------")

def interactive_menu():
    """Menú interactivo para seleccionar e instalar un LLM."""
    print(f"\n{YELLOW}Selecciona una opción para descargar un modelo:{NC}")
    print(f"1) {GREEN}qwen2.5-coder:7b{NC}   (Recomendado: Excelente en código y scripts)")
    print(f"2) {GREEN}qwen2.5-coder:1.5b{NC} (Ligero: Muy rápido, bajo consumo de VRAM)")
    print(f"3) {GREEN}llama3.1:8b{NC}        (Generalista: Potente y equilibrado)")
    print(f"4) {GREEN}codellama:7b{NC}       (Especializado: Generación de código de Meta)")
    print(f"5) [Escribir otro modelo manualmente]")
    print(f"6) Salir / Mantener modelos actuales")

    opcion = input(f"\nIntroduce el número de tu opción: ").strip()
    
    modelo = ""
    if opcion == "1":
        modelo = "qwen2.5-coder:7b"
    elif opcion == "2":
        modelo = "qwen2.5-coder:1.5b"
    elif opcion == "3":
        modelo = "llama3.1:8b"
    elif opcion == "4":
        modelo = "codellama:7b"
    elif opcion == "5":
        print(f"\nPuedes buscar nombres de modelos en: https://ollama.com/library")
        modelo = input("Introduce el nombre exacto del modelo (ej. gemma2:2b): ").strip()
    else:
        print(f"\n{YELLOW}[!] Saltando descarga. Iniciando entorno...{NC}")
        return

    if modelo:
        print(f"\n{YELLOW}[+] Solicitando la descarga de {GREEN}{modelo}{YELLOW} en Ollama...{NC}")
        print(f"{CYAN}(Esto puede tardar unos minutos dependiendo de tu conexión a internet){NC}\n")
        
        # Ejecutamos permitiendo que la barra de progreso nativa se pinte en la terminal
        success, _ = run_command(f"docker exec -it ollama_server ollama pull {modelo}")
        if success:
            print(f"\n{GREEN}[✓] ¡Modelo {modelo} descargado con éxito!{NC}")
        else:
            print(f"\n{RED}[-][Error] No se pudo descargar el modelo. Verifica el nombre o tu conexión.{NC}")

def print_summary():
    """Resumen final de accesos al sistema."""
    print(f"\n{CYAN}======================================================{NC}")
    print(f"{GREEN}     ¡ENTORNO KALIWEBUI COMPLETAMENTE CONFIGURADO!    {NC}")
    print(f"{CYAN}======================================================{NC}")