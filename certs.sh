#!/bin/bash
set -euo pipefail

EMAIL="root@ai-x.website"

DOMAINS=(
  "${DOMAIN_GITEA}"
  "${DOMAIN_DRONE}"
  "${DOMAIN_REGISTRY}"
)

if ! command -v certbot &> /dev/null; then
    sudo apt update
    sudo apt install -y certbot
fi

docker stop nginx 2>/dev/null || true

for domain in "${DOMAINS[@]}"; do
    
    if [ -d "/etc/letsencrypt/live/$domain" ]; then
        sudo certbot renew --cert-name "$domain" --standalone
    else
        sudo certbot certonly \
            --standalone \
            --preferred-challenges http \
            --email "$EMAIL" \
            --agree-tos \
            --no-eff-email \
            --non-interactive \
            -d "$domain"
    fi
    
    SERVICE="${domain%%.*}"
    CERT_DIR="$HOME/infrastructure/nginx/data/certs/$SERVICE"
    
    mkdir -p "$CERT_DIR"
    
    sudo cp "/etc/letsencrypt/live/$domain/fullchain.pem" "$CERT_DIR/"
    sudo cp "/etc/letsencrypt/live/$domain/privkey.pem" "$CERT_DIR/"
    
    sudo chown -R $USER:$USER "$CERT_DIR"
    chmod 644 "$CERT_DIR"/*.pem
    
done