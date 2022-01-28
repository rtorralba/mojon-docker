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

# Modify game settings
GAME = lala_beta
GAME_SCREENS_WIDTH = 6 # If change that you shoul modify config.h too
GAME_SCREENS_HEIGHT = 5 # If change that you shoul modify config.h too

UTILS_DIR = /src/utils/
GFX_DIR = /src/gfx/
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


clean-mojon-docker-git: # Clean original repository
	rm -rf .git
	rm -rf .gitignore

init:  ## Clone MK1 repository and Clean original repository
	$(MAKE) clone-mk1
	$(MAKE) clean-mojon-docker-git
	$(MAKE) create-ponedor-links

build: ## Build game
	$(MAKE) convert-map
	$(MAKE) convert-enemies
	$(MAKE) importing-enemies
	$(MAKE) compile
	$(MAKE) build-tap
	$(MAKE) clean

bash: ## Execute bash
	U_ID=${UID} ${DOCKER_COMMAND} exec app /bin/sh

fix-utils-perms: ## Fix utils perms 
	chmod -R 764 src/utils/

convert-map: ## Convert map
	${WINE} ${UTILS_DIR}mapcnv.exe /src/map/mapa.map /src/dev/assets/mapa.h ${GAME_SCREENS_WIDTH} ${GAME_SCREENS_HEIGHT} 15 10 15 packed

convert-enemies: ## Convirting enemies/hotspots
	${WINE} ${UTILS_DIR}ene2h.exe /src/enems/enems.ene /src/dev/assets/enems.h

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

convert-music: ## Covert music
	${WINE} ${UTILS_DIR}asm2z88dk.exe /src/mus/48k.asm /src/dev/sound/music.h
	sed -i '/org 60000/d' /src/dev/sound/music.h

BEEPER_H = src/dev/sound/beeper.h

convert-effects: ## Convert effects
	${WINE} ${UTILS_DIR}asm2z88dk.exe /src/mus/efectos.asm /${BEEPER_H}
	sed -i '/org 60000/d' ${BEEPER_H}
	echo 'void beep_fx (unsigned char n) {' >> ${BEEPER_H}
	echo 'asm_int = n;' >> ${BEEPER_H}
	echo '#asm' >> ${BEEPER_H}
	echo '	push ix' >> ${BEEPER_H}
	echo '	push iy' >> ${BEEPER_H}
	echo '	ld a, (_asm_int)' >> ${BEEPER_H}
	echo '	call sound_play' >> ${BEEPER_H}
	echo '	pop ix' >> ${BEEPER_H}
	echo '	pop iy' >> ${BEEPER_H}
	echo '#endasm' >> ${BEEPER_H}
	echo '}' >> ${BEEPER_H}

compile: ## Compiling game
	docker run --user ${UID} -v ${PWD}/src:/src --workdir /src/dev -it rtorralba/z88dk-mojon zcc +zx -vn mk1.c -O3 -crt0=crt.asm -o ${GAME}.bin -lsplib2_mk2.lib -zorg=24000

build-tap: ## Build TAP
	${WINE} ${UTILS_DIR}bas2tap -a10 -sLOADER /src/dev/loader/loader.bas /src/dev/loader.tap
	${WINE} ${UTILS_DIR}bin2tap -o /src/dev/screen.tap -a 16384 /src/loading.bin 
	${WINE} ${UTILS_DIR}bin2tap -o /src/dev/main.tap -a 24000 /src/dev/${GAME}.bin 
	cat src/dev/loader.tap src/dev/screen.tap src/dev/main.tap > src/dev/${GAME}.tap

clean: ## Clean generated files
	rm -f src/dev/loader.tap src/dev/screen.tap src/dev/main.tap
	rm -f src/*.bin
	rm -f src/gfx/*.scr

refresh-map: ## Covert only map and enemies
	$(MAKE) convert-map
	$(MAKE) convert-enemies
	$(MAKE) compile
	$(MAKE) build-tap

create-ponedor-links:
	ln -s ../utils/ponedor.exe src/enems/ponedor.exe
	ln -s ../utils/zlib1.dll src/enems/zlib1.dll

ponedor: ## Open ponedor
	wine src/enems/ponedor.exe src/enems/enems.ene

mappy: ## Open mappy
	wine utils/Mappy-mojono/Mappy/mapwin.exe

game: ## Execute game on fuse
	fuse src/dev/${GAME}.tap
