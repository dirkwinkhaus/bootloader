.DEFAULT_GOAL := new_start

.PHONY: build
build:
	docker build -f docker/build/build.dockerfile -t widi/bootloader .

.PHONY: start
start: stop
	docker container list | grep bootloader-compile || docker rm bootloader-compile
	docker run --name bootloader-compile -d -v ${PWD}:/build -it widi/bootloader

.PHONY: stop
stop:
	docker ps | grep bootloader-compile && docker stop bootloader-compile || true

.PHONY: bash
bash:
	docker run -v ${PWD}:/build -it widi/bootloader /bin/bash

.PHONY: build compile-explorer
compile-explorer:
	docker run -v ${PWD}:/build -it widi/bootloader 'cd /build/src/explorer && nasm explorer.asm -f elf -o /build/disc_data/explorer.do'

.PHONY: compile
compile:
	docker exec bootloader-compile /build/scripts/compile.sh










########################################################################################################################################

old_explorer:
	cd src/explorer && nasm explorer.asm -f elf -o ../../disc_data/explorer.do

old_reboot:
	cd src/reboot && nasm reboot.asm -f elf -o ../../disc_data/reboot.do

old_bootfile:
	cd src/bootfile && nasm bootfile.asm -f bin -o ../../disc_data/bootfile.do

old_kernel:
	cd src/kernel && nasm kernel.asm -f bin -o ../../rc/kernel.bin

old_burn:
	ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc\kernel.bin -output rc\preOS.iso -file disc_data\file.txt -file disc_data\bootfile.do -file disc_data\reboot.do -directory disc_data\directory
	# ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc/kernel.bin -output rc/preOS.iso -file disc_data/file.txt -file disc_data/bootfile.do -file disc_data/reboot.do -directory disc_data/directory

old_run:
	qemu-system-i386 -cdrom rc/preOS.iso

old_debug:
	gdb -x debug.gdb

old_build: explorer reboot bootfile kernel burn run

########################################################################################################################################
