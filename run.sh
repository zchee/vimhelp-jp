#!/bin/bash
set -x

docker-compose stop dev vimhelp_jp-submodules
docker-compose rm -f dev vimhelp_jp-submodules

docker-compose build dev
docker-compose up -d dev

docker logs -f vimhelp_jp_dev
