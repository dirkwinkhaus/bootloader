#!/bin/bash

#gdb -x /build/debug.gdb

#qemu-system-i386 -hda /build/debug.gdb -S -s &
#gdb -ex 'set architecture i8086' \
#    -ex 'break *0x7c00' \
#    -ex 'continue'

qemu-system-x86_64 -s -S -kernel bzImage -hda /build/rc/preOS.iso -append "root=/dev/hda"
gdb -ex 'target remote localhost:1234' \
    -ex 'set architecture i8086' \
    -ex 'break *0x7c00' \
    -ex 'continue'
