.DEFAULT_GOAL := setup

# general vars

release_directory = /release
content_directory = /release/content

# general commands

setup: setup-compiler

compile:

stop: remove-compiler

# boot targets

compile-bootfile.bin: working_dirctory = /source/boot
compile-bootfile.bin:
	docker exec -i compiler \
	gcc -m32 -Wall -Wextra -nostdlib -nostartfiles -nodefaultlibs -c $(working_dirctory)/bootfile.c -o $(working_dirctory)/bootfile.o && \
	docker exec -i compiler \
	ld -T $(working_dirctory)/bootfile.ld -m elf_i386 -o $(content_directory)/bootfile.bin $(working_dirctory)/bootfile.o

compile-bootloader.bin: working_dirctory = /source/boot
compile-bootloader.bin:
	docker exec -i compiler bash -c \
	"cd $(working_dirctory) && nasm bootloader.asm -f bin -o $(release_directory)/bootloader.bin"

compile-boot: compile-bootloader.bin compile-bootfile.bin

#infrastructure

build-compiler:
	docker build -t widi/preos-compiler src/infrastructure/docker/

setup-compiler: build-compiler
	docker run -v `pwd`/src:/source -v `pwd`/rc:/release --name=compiler -d -it widi/preos-compiler

bash-compiler:
	docker exec -it compiler /bin/bash

start-compiler:
	docker start compiler

stop-compiler:
	docker stop compiler

remove-compiler: stop-compiler
	docker rm compiler

# summarized infrastructure targets

release-clean: compile
	cd rc && find ./ ! -name '.gitignore' ! -name '.' ! -name content -exec rm -fr {} \;

clean: release-clean remove-compiler

setup: setup-compiler

burn:
	docker exec -i compiler \
	genisoimage -verbose -eltorito-boot /release/bootloader.bin -joliet -rational-rock -volid PREOS -output /release/preos.iso /release/content

compile: compile-boot

run:
	qemu-system-i386 -cdrom rc\preos.iso

