#!/bin/bash
set -x

docker-compose stop
docker-compose rm -f
docker-compose build
docker-compose up -d
# docker stop vimhelp-jp-dev && docker rm vimhelp-jp-dev
# docker build -t zchee/vimhelp-jp-dev . && docker run -d --name vimhelp-jp-dev -e VIRTUAL_HOST=vimhelp-jp-dev.zchee.io -e VIRTUAL_PORT=80 zchee/vimhelp-jp-dev
