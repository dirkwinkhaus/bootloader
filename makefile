.DEFAULT_GOAL := setup

# general vars

release_directory = /release

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
	ld -T $(working_dirctory)/bootfile.ld -m elf_i386 -o $(release_directory)/bootfile.bin $(working_dirctory)/bootfile.o

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

clean: remove-compiler

setup: setup-compiler

compile: compile-boot

release-clean: compile
	cd rc && find ./ ! -name '.gitignore' ! -name '.' ! -content '.' -exec rm -fr {} \; && cd - && \

run:
	qemu-system-i386  -kernel rc/bootloader

