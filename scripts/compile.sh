#!/bin/bash

cd /build/src/explorer && nasm explorer.asm -f elf -o ../../data/explorer.do
cd /build/src/reboot && nasm reboot.asm -f elf -o ../../data/reboot.do
cd /build/src/bootfile && nasm bootfile.asm -f bin -o ../../data/bootfile.do
cd /build/src/kernel && nasm kernel.asm -f bin -o ../../data/boot/kernel.bin