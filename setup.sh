#!/bin/bash

docker buildx build -t bdp-backend backend
docker buildx build -t bdp-frontend frontend

docker-compose up -d
