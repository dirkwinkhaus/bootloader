#infrastructure

setup: setup-compiler

stop: remove-compiler

build-compiler:
	docker build -t widi/preos-compiler src/infrastructure/docker/

setup-compiler: build-compiler
	docker run -v `pwd`/iso:/iso -v `pwd`/src:/source -v `pwd`/rc:/release --name=compiler -d -it widi/preos-compiler

bash-compiler:
	docker exec -it compiler /bin/bash

start-compiler:
	docker start compiler

stop-compiler:
	docker stop compiler

remove-compiler: stop-compiler
	docker rm compiler

# summarized infrastructure targets

prepare-release:
	mkdir -p rc/boot/grub

release-clean:
	cd rc && find ./ ! -name '.gitignore' ! -name '.' -exec rm -fr {} \;

clean: release-clean remove-compiler

setup: setup-compiler

burn:
	docker exec -i compiler \
	grub-mkrescue -o /iso/preos.iso /release

compile: compile-kernel
	cp src/infrastructure/grub/grub.cfg rc/boot/grub

run: burn
	qemu-system-i386 -cdrom preos.iso

all: clean setup compile burn run