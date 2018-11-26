# boot targets

compile-kernel: working_dirctory = /source/kernel
compile-kernel: prepare-release
	docker exec -i compiler \
	i686-elf-as $(working_dirctory)/kernel.asm -o $(working_dirctory)/kernel_asm.o
	docker exec -i compiler \
	i686-elf-gcc -c $(working_dirctory)/kernel.c -o $(working_dirctory)/kernel_c.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	docker exec -i compiler \
	i686-elf-gcc -T $(working_dirctory)/kernel.ld -o $(release_directory)/boot/kernel.bin -ffreestanding -O2 -nostdlib $(working_dirctory)/kernel_asm.o $(working_dirctory)/kernel_c.o -lgcc
