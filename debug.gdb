# add-symbol-file data/boot/kernel.bin 0x7c00
# add-symbol-file data/bootfile.do
add-symbol-file data/explorer.do
add-symbol-file data/reboot.do

break *0x7c00
break *0x10000
target remote | qemu-system-i386 -S -gdb stdio -cdrom rc/preOS.iso
