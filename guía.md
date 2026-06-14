🐉 Guía de Integración: Open WebUI + MCP en Kali Linux Workspace
Esta guía detalla cómo utilizar el Model Context Protocol (MCP) para conectar la interfaz de Open WebUI con tu contenedor de auditoría Kali Linux Workspace.

🏗️ 1. Arquitectura del Sistema
Para entender cómo interactúan los componentes de este proyecto, es fundamental conocer cómo se salva la brecha de comunicación entre ellos:

Servidores MCP Nativos (stdio): Herramientas como @modelcontextprotocol/server-filesystem se comunican de forma nativa a través de la entrada y salida estándar (stdio) de la terminal.

Requisito de Open WebUI (HTTP): Open WebUI no puede leer directamente procesos en stdio de otros contenedores; requiere conectarse a servicios a través de endpoints Streamable HTTP o APIs compatibles con OpenAPI.

El Orquestador (mcpo): Dentro del contenedor de Kali, la herramienta mcpo actúa como un puente (Proxy/Bridge). Lee un archivo de configuración (mcp-config.json), levanta los servidores MCP en stdio y los expone como servicios HTTP en el puerto 8000 a través de la red interna de Docker (kaliwebui_net).

⚙️ 2. Configuración Técnica del Proyecto
Para que el ecosistema funcione automáticamente al ejecutar el script init.sh, asegúrate de que los archivos del proyecto incluyan las siguientes directivas:

A. Dockerfile (Sección MCP)
El archivo Dockerfile instala el servidor de archivos de Node.js, la herramienta de orquestación mcpo y genera la configuración inicial:

Dockerfile
# Instalación del servidor MCP nativo de Filesystem
RUN npm install -g @modelcontextprotocol/server-filesystem

# Instalación de mcpo (MCP Proxy) y dependencias de Python
RUN pip3 install --no-cache-dir --break-system-packages mcpo duckduckgo-search openai

# Creación del archivo de configuración para el proxy MCP
RUN mkdir -p /etc/mcp && echo '{\n\
  "mcpServers": {\n\
    "filesystem": {\n\
      "command": "npx",\n\
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/kali", "/workspace/outputs"]\n\
    }\n\
  }\n\
}' > /etc/mcp/mcp-config.json

EXPOSE 8000
B. entrypoint.sh (Lanzamiento del Servicio)
En lugar de finalizar con un bucle inactivo, el script de entrada ejecuta el proxy para mantener el contenedor escuchando peticiones en red:

Bash
echo "[ok] Kali Workspace listo. Iniciando Proxy MCP en puerto 8000..."
# Reemplaza el 'tail -f /dev/null' por la ejecución nativa de mcpo:
exec mcpo --config /etc/mcp/mcp-config.json --port 8000 --host 0.0.0.0
🚀 3. Puesta en Marcha Paso a Paso
Paso 1: Inicializar el Entorno
Ejecuta el script interactivo en tu terminal para levantar los contenedores y descargar el modelo de lenguaje de tu elección (ej. qwen2.5-coder:7b):

Bash
chmod +x init.sh
./init.sh
Paso 2: Vincular el Servidor MCP en Open WebUI
Abre tu navegador web e ingresa a Open WebUI (http://localhost:3000).

Regístrate o inicia sesión con tu cuenta de administrador.

Dirígete al Panel de Administración (esquina inferior izquierda) -> Ajustes -> Herramientas Externas (External Tools / Connections).

Haz clic en Añadir Servidor de Herramientas (Add Tool Server).

Configura los siguientes campos en el formulario:

Nombre: Kali MCP Workspace

URL del Servidor: http://kali:8000 (Usamos el nombre del servicio de Docker, ya que Open WebUI y Kali comparten la red kaliwebui_net).

Tipo de Autenticación: None (La conexión es interna y segura dentro del entorno bridge de Docker).

Haz clic en Guardar. Open WebUI consultará el endpoint, asimilará las herramientas del sistema de archivos y las registrará automáticamente.

🛠️ 4. Modo de Uso en el Chat
Una vez vinculado, el modelo de IA seleccionado tendrá superpoderes para interactuar con tu entorno de Kali:

Activación de Herramientas
Automática: Si le pides al modelo algo como "Revisa si hay archivos de texto en mi home y lístalos", el LLM llamará al servidor MCP de forma autónoma.

Manual: Puedes forzar el uso de una herramienta específica escribiendo el símbolo # en el cuadro de texto del chat y seleccionando la herramienta correspondiente del listado desplegable.

Ejemplos de Interacción Práctica
📥 Usuario: "Crea un script de Python en mi carpeta de scripts que automatice un escaneo rápido de Nmap a la IP 192.168.1.1 y guarda el resultado en /home/kali/evidences/nmap_report.txt."
🤖 IA: (Usará el servidor MCP filesystem para escribir el archivo directamente en el volumen compartido de tu contenedor de Kali).

🔍 Usuario: "Lee el archivo de evidencias feroxbuster_output.txt que acabo de generar en mi consola de Kali y hazme un resumen de los directorios web encontrados."
🤖 IA: (Leerá el contenido del archivo de forma nativa a través de MCP y te presentará el análisis estructurado en la interfaz web).

⚠️ 5. Notas de Seguridad Importantes
[!WARNING]

Aislamiento de Archivos: El servidor de archivos configurado en esta guía tiene acceso explícito a /home/kali y /workspace/outputs. No expongas rutas del sistema operativo anfitrión (Host) a menos que sea estrictamente necesario.

Red Local: El puerto 8000 en el docker-compose.yml está expuesto bajo 127.0.0.1. Esto evita que cualquier otra máquina de tu red local pueda interactuar con el proxy de tu entorno de Kali. No cambies esta directiva a 0.0.0.0 en entornos de red públicos o inseguros.