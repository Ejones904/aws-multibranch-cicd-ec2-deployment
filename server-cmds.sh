#!/usr/bin/env bash

set -e

IMAGE=$1

echo "Deploying image: $IMAGE"

docker pull "$IMAGE"

docker rm -f java-maven-app 2>/dev/null || true

docker run -d \
    --name java-maven-app \
    -p 3000:8080 \
    "$IMAGE"

echo "Deployment successful"

docker ps