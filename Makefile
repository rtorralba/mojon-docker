#!/bin/bash

DOCKER_CONTAINER = app
OS := $(shell uname)

ifeq ($(OS),Darwin)
    UID = $(shell id -u)
else ifeq ($(OS),Linux)
	UID = $(shell id -u)
else
	UID = 1000
endif

DOCKER_COMMAND = docker-compose -f .docker/docker-compose.yml
UTILS_DIR = /src/utils/
GAME = lala_beta
WINE = docker run -v ${PWD}/src:/src -it --platform linux/386 rtorralba/wine-mojon wine

help: ## Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

clone-mk1: ## Clone MK1 repository
	git clone git@github.com:mojontwins/MK1.git
	mv MK1/src .
	rm -rf MK1
	bash comment-empty-includes.sh

run: ## Run container
	U_ID=${UID} ${DOCKER_COMMAND} up -d

stop: ## Stop container
	U_ID=${UID} ${DOCKER_COMMAND} stop

build: ## Build game
	$(MAKE) convert-map
	$(MAKE) convert-enemies
	$(MAKE) importing-enemies
	$(MAKE) compile
	$(MAKE) build-tap


bash: ## Execute bash
	U_ID=${UID} ${DOCKER_COMMAND} exec app /bin/sh

fix-utils-perms: ## Fix utils perms 
	chmod -R 764 src/utils/

convert-map: ## Convert map
	${WINE} ${UTILS_DIR}mapcnv.exe /src/map/mapa.map /src/dev/assets/mapa.h 6 5 15 10 15 packed

convert-enemies: ## Convirting enemies/hotspots
	${WINE} ${UTILS_DIR}ene2h.exe /src/enems/enems.ene /src/dev/assets/enems.h

GFX_DIR = /src/gfx/
importing-enemies: ## Importing GFX
	${WINE} ${UTILS_DIR}ts2bin.exe ${GFX_DIR}font.png ${GFX_DIR}work.png /src/dev/tileset.bin 7

	${WINE} ${UTILS_DIR}sprcnv.exe ${GFX_DIR}sprites.png /src/dev/assets/sprites.h

	${WINE} ${UTILS_DIR}sprcnvbin.exe ${GFX_DIR}sprites_extra.png sprites_extra.bin 1
	${WINE} ${UTILS_DIR}sprcnvbin8.exe ${GFX_DIR}sprites_bullet.png sprites_bullet.bin 1

	${WINE} ${UTILS_DIR}png2scr.exe ${GFX_DIR}title.png ${GFX_DIR}title.scr
	${WINE} ${UTILS_DIR}png2scr.exe ${GFX_DIR}marco.png ${GFX_DIR}marco.scr
	${WINE} ${UTILS_DIR}png2scr.exe ${GFX_DIR}ending.png ${GFX_DIR}ending.scr
	${WINE} ${UTILS_DIR}png2scr.exe ${GFX_DIR}loading.png /src/loading.bin
	${WINE} ${UTILS_DIR}apultra.exe ${GFX_DIR}title.scr /src/bin/title.bin
	${WINE} ${UTILS_DIR}apultra.exe ${GFX_DIR}marco.scr /src/bin/marco.bin
	${WINE} ${UTILS_DIR}apultra.exe ${GFX_DIR}ending.scr /src/bin/ending.bin

compile: # Compiling game
	docker run --user ${UID} -v ${PWD}/src:/src --workdir /src/dev -it rtorralba/z88dk-mojon zcc +zx -vn mk1.c -O3 -crt0=crt.asm -o ${GAME}.bin -lsplib2_mk2.lib -zorg=24000

build-tap: # Build TAP
	${WINE} ${UTILS_DIR}bas2tap -a10 -sLOADER /src/dev/loader/loader.bas /src/dev/loader.tap
	${WINE} ${UTILS_DIR}bin2tap -o /src/dev/screen.tap -a 16384 /src/loading.bin 
	${WINE} ${UTILS_DIR}bin2tap -o /src/dev/main.tap -a 24000 /src/dev/${GAME}.bin 
	cat src/dev/loader.tap src/dev/screen.tap src/dev/main.tap > src/dev/${GAME}.tap

clean:
	rm src/dev/loader.tap src/dev/screen.tap src/dev/main.tap
	rm src/gfx/*.src
	rm src/*.bin