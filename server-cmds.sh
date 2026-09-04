#!/usr/bin/env bash

set -e

IMAGE="$1"
export IMAGE

COMPOSE_FILE="/home/ec2-user/docker-compose.yaml"

echo "Deploying image: $IMAGE"

if command -v docker-compose >/dev/null 2>&1; then
    docker-compose -f "$COMPOSE_FILE" up -d
elif docker compose version >/dev/null 2>&1; then
    docker compose -f "$COMPOSE_FILE" up -d
else
    echo "ERROR: Docker Compose is not installed on this EC2 instance."
    exit 1
fi

echo "Deployment successful"