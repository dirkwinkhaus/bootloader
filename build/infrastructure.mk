#infrastructure

setup: setup-compiler

stop: remove-compiler

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
	qemu-system-i386 -cdrom iso/preos.iso

all: clean setup compile burn run