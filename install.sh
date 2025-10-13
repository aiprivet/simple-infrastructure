#!/bin/bash
set -euo pipefail

sudo apt update


if ! command -v docker &> /dev/null; then
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    sudo apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    sudo usermod -aG docker $USER
    
fi

if ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
fi

if ! command -v certbot &> /dev/null; then
    sudo apt install -y certbot
fi

if ! docker network ls | grep -q "infra"; then
    docker network create infra
fi

if [ -d "~/infrastructure" ]; then
    git clone https://github.com/aivanov-ai/infrastructure.git ~/infrastructure
else
    cd ~/infrastructure
    git pull
fi
    cd ~/infrastructure
    bash setup-cron.sh
    bash auto-update.sh

bash create-nginx-conf.sh