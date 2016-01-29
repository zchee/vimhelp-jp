# Global commands
DOCKER_CMD := docker
# empty of CURL_CA_BUNDLE is docker-compose bug
DOCKER_COMPOSE_CMD := CURL_CA_BUNDLE= docker-compose

# for command line environment variables
DEV := false
DAEMON := true

# Switch launch compso service
ifeq ($(DEV),false)
DOCKER_COMPOSE_SERVICE := bot
else
DOCKER_COMPOSE_SERVICE := dev
endif
DOCKER_COMPOSE_CONTAINER := vimhelp_jp_${DOCKER_COMPOSE_SERVICE}

# docker-compose sub-commands
DOCKER_COMPOSE_BUILD := ${DOCKER_COMPOSE_CMD} build
ifeq (${DAEMON},true)
DOCKER_COMPOSE_UP := ${DOCKER_COMPOSE_CMD} up -d
else
DOCKER_COMPOSE_UP := ${DOCKER_COMPOSE_CMD} up
endif

# Parse 'none' images
DOCKER_IMAGE_NONE := $(shell ${DOCKER_CMD} images | awk '/^<none>/ { print $$3 }')

default: log

build:
	${DOCKER_COMPOSE_BUILD} ${DOCKER_COMPOSE_SERVICE}

up: build
	${DOCKER_COMPOSE_UP} ${DOCKER_COMPOSE_SERVICE}

log: clean build up
	${DOCKER_CMD} logs -f ${DOCKER_COMPOSE_CONTAINER}

ifeq (${DOCKER_IMAGE_NONE},)
$(info Not exists 'none' image)
clean:
	@true
else
clean: clean-image
endif

clean-image:
	${DOCKER_CMD} rmi ${DOCKER_IMAGE_NONE}

.PHONY: build up log clean clean-image
