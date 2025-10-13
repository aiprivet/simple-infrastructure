#!/bin/bash
# create-nginx-conf.sh

set -a 
source .env
set +a

# Теперь envsubst видит все переменные из .env
envsubst < nginx/conf.d/drone.conf.template > nginx/conf.d/drone.conf
envsubst < nginx/conf.d/registry.conf.template > nginx/conf.d/registry.conf
envsubst < nginx/conf.d/gitea.conf.template > nginx/conf.d/gitea.conf

echo "Nginx configs generated from templates"