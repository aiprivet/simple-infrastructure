#!/bin/bash
set -euo pipefail

INFRA_PATH='/home/iamshine/infrastructure'
ls ${INFRA_PATH}
docker compose --env-file ${INFRA_PATH}/.env -p infra \
  -f ${INFRA_PATH}/gitea/docker-compose.yml \
  -f ${INFRA_PATH}/registrty/docker-compose.yml \
  -f ${INFRA_PATH}/drone/docker-compose.yml \
  -f ${INFRA_PATH}/nginx/docker-compose.yml \
  up -d

