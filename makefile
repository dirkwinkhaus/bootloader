.DEFAULT_GOAL := build

explorer:
	cd src/explorer && nasm explorer.asm -f bin -o ../../disc_data/explorer.do

reboot:
	cd src/reboot && nasm reboot.asm -f bin -o ../../disc_data/reboot.do

bootfile:
	cd src/bootfile && nasm bootfile.asm -f bin -o ../../disc_data/bootfile.do

kernel:
	cd src/kernel && nasm kernel.asm -f bin -o ../../rc/kernel.bin

burn:
	del rc/preOS.iso && ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc/kernel.bin -output rc/preOS.iso -file disc_data/file.txt -file disc_data/bootfile.do -file disc_data/reboot.do -directory disc_data/directory

run:
	qemu-system-i386 -cdrom rc/preOS.iso

build: explorer reboot bootfile kernel burn run

explorer-win:
	cd src\explorer && nasm explorer.asm -f bin -o ..\..\disc_data\explorer.do

reboot-win:
	cd src\reboot && nasm reboot.asm -f bin -o ..\..\disc_data\reboot.do

bootfile-win:
	cd src\bootfile && nasm bootfile.asm -f bin -o ..\..\disc_data\bootfile.do

kernel-win:
	cd src\kernel && nasm kernel.asm -f bin -o ..\..\rc\kernel.bin

burn-win:
	del rc\preOS.iso && ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc\kernel.bin -output rc\preOS.iso -file disc_data\file.txt -file disc_data\bootfile.do -file disc_data\reboot.do -directory disc_data\directory

run-win:
	qemu-system-i386 -cdrom rc\preOS.iso

build-win: explorer-win reboot-win bootfile-win kernel-win burn-win run-win
