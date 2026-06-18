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
    arp-scan \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gunzip /usr/share/wordlists/rockyou.txt.gz || true

# ==============================================================================
# 5. INTEGRACIÓN CON OPEN TERMINAL 
# ==============================================================================
# Instalamos open-terminal y las librerías de soporte
RUN pip3 install --no-cache-dir --break-system-packages \
    open-terminal \
    duckduckgo-search \
    openai

# Cliente de Docker estático (opcional)
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz | tar -xzf - --strip-components=1 -C /usr/bin/ docker/docker

# ==============================================================================
# 6. ENTORNO DE EJECUCIÓN
# ==============================================================================
RUN apt-get update && apt-get install -y dos2unix && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN dos2unix /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/kali

EXPOSE 8000

# Arrancamos como root para que el entrypoint configure permisos si es necesario
USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]