.DEFAULT_GOAL := build

# general commands

setup: setup-compiler

compile:

stop: remove-compiler

# boot targets

compile-bootfile.bin: working_dirctory = /source/boot
compile-bootfile.bin:
	docker exec -it compiler \
	gcc -m32 -Wall -Wextra -nostdlib -nostartfiles -nodefaultlibs -c $(working_dirctory)/bootfile.c -o $(working_dirctory)/bootfile.o && \
	docker exec -it compiler \
	ld -T $(working_dirctory)/bootfile.ld -m elf_i386 -o $(working_dirctory)/bootfile.bin $(working_dirctory)/bootfile.o

compile-bootloader.bin: working_dirctory = /source/boot
compile-bootloader.bin:
	docker exec -i compiler bash -c \
	"cd $(working_dirctory) && nasm bootloader.asm -f bin -o bootloader.bin"

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

clean: remove-compiler

setup: setup-compiler

compile: compile-boot

release: compile
	cd rc && find ./ ! -name '.gitignore' ! -name '.' -exec rm -fr {} \; && cd - && \
	mv src/boot/bootfile.bin rc/ && \
	mv src/boot/bootloader.bin rc/

run:
	qemu-system-i386  -kernel rc/bootloader

