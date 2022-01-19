# Project

## Description

Features:

* Show current demand plan sorted by product group and country
* Graph comparison between budget, demand and production
* Allow to edit current demand plan for each product
* Warn user whenever demand exceeds production

## Dependencies

* [Docker](docker.com)
* [docker-compose](https://github.com/docker/compose)

On Arch:
```
sudo pacman -S docker docker-compose
```

To run `docker` without `sudo` you need to add user to docker group: [link](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

## Build

Either run script `setup.sh` (it requires `docker buildx`) or run:
```
docker build -t bdp-backend backend
docker build -t bdp-frontend frontend

docker-compose up -d
```
Afterwards three containers should be running (database takes up to 4 minutes to boot up)

## Using

Frontend runs on port 3000: [http://localhost:3000](http://localhost:3000) and backend on 9090: [http://localhost::9090](http://localhost::9090)
