.DEFAULT_GOAL := new_start

.PHONY: build
build:
	docker build -f docker/build/build.dockerfile -t widi/bootloader .

.PHONY: start
start:
	# docker container list | grep bootloader-compile || docker rm bootloader-compile
	#docker run --name bootloader-compile -d \
make		-v ~/.Xauthority:/root/.Xauthority \
		-v ${PWD}:/build \
	   	-v $DISPLAY:/tmp/.X11-unix \
		-e DISPLAY=$DISPLAY \
		-it widi/bootloader

.PHONY: stop
stop:
	docker ps | grep bootloader-compile && docker stop bootloader-compile || true

.PHONY: bash
bash:
	docker run -v $DISPLAY:/tmp/.X11-unix -v ${PWD}:/build -it widi/bootloader /bin/bash

.PHONY: compile
compile:
	docker exec bootloader-compile /build/scripts/compile.sh

.PHONY: burn
burn:
	docker exec -it bootloader-compile /build/scripts/burn.sh

.PHONY: debug
debug:
	#docker exec -it bootloader-compile /build/scripts/debug.sh
	docker run -v $DISPLAY:/tmp/.X11-unix -v ${PWD}:/build -it widi/bootloader /build/scripts/debug.sh

.PHONY: run
run: compile burn
	docker exec -it bootloader-compile /build/scripts/run.sh

.PHONY: run-local
run-local: compile burn
	qemu-system-i386 -cdrom rc/preOS.iso