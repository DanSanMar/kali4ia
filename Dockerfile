# ==============================================================================
# 1. BASE & CONFIGURACIÓN
# ==============================================================================
FROM kalilinux/kali-rolling:latest 

LABEL maintainer="Seguridad y Auditoría - ALL4me"
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm
ENV TZ=Europe/Madrid

# ==============================================================================
# 2. SISTEMA Y DEPENDENCIAS
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    curl \
    gnupg \
    grep \
    build-essential \
    iproute2 \ 
    net-tools \      
    iputils-ping \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    nodejs \
    npm \
    jq \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 3. USUARIO KALI
# ==============================================================================
RUN id -u kali >/dev/null 2>&1 || \
    (useradd -m -s /bin/bash kali && \
    echo 'kali ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers)

# ==============================================================================
# 4. HERRAMIENTAS DE AUDITORÍA SELECCIONADAS
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    nmap \
    dnsutils \
    netcat-traditional \
    ffuf \
    feroxbuster \
    whatweb \
    wpscan \
    sqlmap \
    nuclei \
    hydra \
    micro \
    unzip \
    fzf \
    ripgrep \
    tmux \
    wordlists \
    gobuster \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gunzip /usr/share/wordlists/rockyou.txt.gz || true

# ==============================================================================
# 5. INTEGRACIÓN MCP (Traducción a HTTP mediante mcpo)
# ==============================================================================
# Instalamos los servidores globales MCP requeridos
RUN npm install -g @modelcontextprotocol/server-filesystem

# Instalamos mcpo para exponer los servidores vía HTTP en el puerto 8000
RUN pip3 install --no-cache-dir --break-system-packages \
    mcpo \
    duckduckgo-search \
    openai

# Crear la configuración de MCPO para indicarle qué herramientas levantar vía stdio
RUN mkdir -p /etc/mcp && echo '{\n\
  "mcpServers": {\n\
    "filesystem": {\n\
      "command": "npx",\n\
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/kali", "/workspace/outputs"]\n\
    }\n\
  }\n\
}' > /etc/mcp/mcp-config.json

# Cliente de Docker estático
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz | tar -xzf - --strip-components=1 -C /usr/bin/ docker/docker

# ==============================================================================
# 6. ENTORNO DE EJECUCIÓN
# ==============================================================================
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/kali

# Exponer explícitamente el puerto del Proxy MCP
EXPOSE 8000

USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]