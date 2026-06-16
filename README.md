# 🐉 KaliWebUI: IA Local con MCP para Auditorías de Seguridad

¡Bienvenido a **KaliWebUI**! Este proyecto despliega un entorno de auditoría y ciberseguridad completamente local, uniendo la potencia de las herramientas de **Kali Linux**, el motor de inferencia de IA **Ollama** (con aceleración por GPU NVIDIA) y la interfaz gráfica **Open WebUI**.

La magia de este ecosistema radica en la integración de **Model Context Protocol (MCP)**, lo que permite que el modelo de lenguaje (LLM) interactúe de forma nativa con el sistema de archivos del contenedor de Kali, ayudándote a escribir scripts, analizar reportes y gestionar tus evidencias en tiempo real.

---

## 🏗️ Arquitectura del Entorno

El proyecto se compone de tres servicios orquestados a través de Docker en una red interna privada (`kaliwebui_net`):

1. **Ollama Server:** Motor de IA local con soporte oficial para GPUs NVIDIA.
2. **Open WebUI:** Interfaz de usuario web intuitiva conectada a Ollama.
3. **Kali Workspace (Servidor MCP):** Un contenedor de Kali Linux con herramientas esenciales de auditoría, que expone un proxy MCP HTTP (`mcpo`) en el puerto `8000` para que la IA lea y escriba en el espacio de trabajo.

---

## 🛠️ Herramientas Incluidas en el Workspace

El contenedor de Kali Linux viene preconfigurado con una selección de herramientas listas para usar:
* **Escaneo y Enumeración:** `nmap`, `dnsutils`, `whatweb`
* **Fuzzing y Directorios:** `ffuf`, `feroxbuster`, `gobuster`
* **Auditoría Web y Explotación:** `sqlmap`, `wpscan`, `nuclei`, `hydra`
* **Utilidades del Sistema:** `tmux`, `micro`, `fzf`, `ripgrep`, diccionario `rockyou` extraído.

---

## 🚀 Requisitos Previos y Compatibilidad

El entorno está diseñado para ser totalmente multiplataforma, pero el rendimiento óptimo y el soporte de GPU varían según el sistema operativo:

### 🐧 En Linux (Ubuntu / Debian nativo)
* **Requisitos:** Docker Engine (evitar versión Snap) y Docker Compose V2 instalado de repositorios oficiales.
* **Aceleración por GPU:** Requiere **NVIDIA Container Toolkit** para dar acceso a la tarjeta gráfica dentro de los contenedores.
* **Permisos:** Asegúrate de añadir tu usuario al grupo Docker (`sudo usermod -aG docker $USER`) para ejecutar el entorno sin usar `sudo`.

### 🪟 En Windows (A través de WSL2)
* **Requisitos:** Docker Desktop configurado obligatoriamente con el motor basado en **WSL2**.
* **Ejecución:** Se recomienda clonar el repositorio y ejecutar los scripts **dentro del sistema de archivos de Linux en WSL2** (ej. `/home/tu_usuario/...`) y no en los discos compartidos de Windows (`/mnt/c/...`) para evitar problemas con permisos POSIX y optimizar el rendimiento.
* **Aceleración por GPU:** Asegúrate de tener los drivers de NVIDIA actualizados en Windows; Docker Desktop se encargará de pasar la GPU a WSL2 de forma automática.

---

### Instrucciones de Arranque

1. Clona este repositorio en tu máquina local:
   ```
   git clone [https://github.com/DanSanMar/kaliwebui.git](https://github.com/DanSanMar/kaliwebui.git)
   ```
2. 
	```
   cd kaliwebui
	```
3. Dale permisos de ejecución al inicializador interactivo que necesites:

    chmod +x init_linux.py
     ```
         
    ```
    chmod +x init.sh
    ```
    
4. Ejecuta el inicializador:
    
    ```
    ./init.sh
    ./init_linux.py
    ```
    

El script `init.sh` o `init_linux.py` se encargará de levantar los contenedores, comprobar la conexión y ofrecerte un menú interactivo en la terminal para descargar el modelo de IA que prefieras (se recomienda `qwen2.5-coder:7b` para tareas de scripting y código).

## 🔗 Conexión de Open WebUI con el Servidor MCP

Para que la IA pueda interactuar con tus carpetas de Kali, debes vincular el servidor MCP en la interfaz web siguiendo estos pasos:

1. Entra en tu navegador a **Open WebUI** en [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000).
    
2. Ve al **Panel de Administración** (esquina inferior izquierda) ➡️ **Ajustes** ➡️ **Herramientas Externas** (_External Tools_).
    
3. Haz clic en **Añadir Servidor de Herramientas** (_Add Tool Server_).
    
4. Rellena los campos con los siguientes datos:
    
    - **Nombre:** `Kali Workspace`
        
    - **URL del Servidor:** `http://kali:8000` _(Nombre del servicio dentro de la red Docker)_
        
    - **Tipo de Autenticación:** `None`
        
5. Haz clic en **Guardar**.
    

¡Listo! A partir de este momento, cuando chatees con la IA, podrás presionar la tecla **`#`** para invocar las herramientas del sistema de archivos de Kali, o dejar que el modelo las use automáticamente cuando le pidas gestionar ficheros.

## 📂 Estructura del Espacio de Trabajo Local

El contenedor mapea dos carpetas locales en la raíz de tu proyecto para que puedas acceder a los archivos desde tu máquina anfitriona sin entrar a Docker:

- `./kali_home`: Mapeado directamente al directorio `/home/kali` del contenedor. Aquí dentro encontrarás de forma automática las carpetas de estructura limpia:
    
    - 📁 `evidences/` -> Para guardar capturas, logs o salidas de comandos.
        
    - 📁 `scripts/` -> Para almacenar scripts de automatización generados por ti o por la IA.
        
    - 📁 `reports/` -> Para tus informes finales de auditoría.
        
- `./outputs`: Carpeta adicional `/workspace/outputs` compartida y autorizada para el servidor de archivos.
    

## 💻 Acceso Directo a la Consola

Si en cualquier momento necesitas ejecutar comandos manualmente dentro de tu entorno de Kali, abre una nueva terminal en tu máquina anfitriona y ejecuta:

Bash

```
docker exec -it kali_workspace /bin/bash
```

## ⚠️ Nota de Seguridad

Este entorno está diseñado para fines educativos, laboratorios locales y auditorías éticas controladas. El puerto `8000` del servidor MCP está expuesto únicamente en `127.0.0.1` en el archivo `docker-compose.yml` para garantizar que nadie fuera de tu máquina local pueda interactuar con tu sistema de archivos de Kali. No expongas este puerto a redes públicas.