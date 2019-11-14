.DEFAULT_GOAL := build

explorer:
	cd src/explorer && nasm explorer.asm -f elf -o ../../disc_data/explorer.do

explorer:
	cd src/explorer && nasm explorer.asm -f elf -o ../../disc_data/explorer.do

reboot:
	cd src/reboot && nasm reboot.asm -f elf -o ../../disc_data/reboot.do

bootfile:
	cd src/bootfile && nasm bootfile.asm -f bin -o ../../disc_data/bootfile.do

kernel:
	cd src/kernel && nasm kernel.asm -f bin -o ../../rc/kernel.bin

burn:
	ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc\kernel.bin -output rc\preOS.iso -file disc_data\file.txt -file disc_data\bootfile.do -file disc_data\reboot.do -directory disc_data\directory
	# ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc/kernel.bin -output rc/preOS.iso -file disc_data/file.txt -file disc_data/bootfile.do -file disc_data/reboot.do -directory disc_data/directory

run:
	qemu-system-i386 -cdrom rc/preOS.iso

debug:
	gdb -x debug.gdb

build: explorer reboot bootfile kernel burn run
