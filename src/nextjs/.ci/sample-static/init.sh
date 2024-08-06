#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ws harness prepare

PROJECT_NAME="$(docker compose config --format json | jq -r '.name')"
CONTAINER_NAME="${PROJECT_NAME}-install"

docker run --name "${CONTAINER_NAME}"  --entrypoint '' --workdir /app node:20-slim bash -c "npm init next-app -- /app --ts --eslint --tailwind --src-dir --app --import-alias '@/*' && npm pkg set scripts.test:unit=true && npm pkg set scripts.test:acceptance=true"
docker cp "${CONTAINER_NAME}:/app/." ./
docker rm --force "${CONTAINER_NAME}"
