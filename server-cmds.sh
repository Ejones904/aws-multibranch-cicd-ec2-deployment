#!/usr/bin/env bash

set -e

export IMAGE=$1

docker compose -f /home/ec2-user/docker-compose.yaml up --detach

echo "Deployment successful"