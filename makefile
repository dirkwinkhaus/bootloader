.DEFAULT_GOAL := build

explorer:
	cd src\real_mode\explorer && nasm explorer.asm -f bin -o ..\..\..\disc_data\explorer.do

reboot:
	cd src\real_mode\reboot && nasm reboot.asm -f bin -o ..\..\..\disc_data\reboot.do

bootfile:
	cd src\real_mode\bootfile && nasm bootfile.asm -f bin -o ..\..\..\disc_data\bootfile.do

kernel:
	cd src\real_mode\kernel && nasm kernel.asm -f bin -o ..\..\..\rc\kernel.bin

burn:
	del rc\preOS.iso && ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile rc\kernel.bin -output rc\preOS.iso -file disc_data\file.txt -file disc_data\bootfile.do -file disc_data\reboot.do -directory disc_data\directory

run:
	qemu-system-i386 -cdrom rc\preOS.iso

build: explorer reboot bootfile kernel burn run