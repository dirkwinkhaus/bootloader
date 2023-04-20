#!/bin/bash

cd /build/src/explorer && nasm explorer.asm -f elf -o ../../disc_data/explorer.do
cd /build/src/reboot && nasm reboot.asm -f elf -o ../../disc_data/reboot.do
cd /build/src/bootfile && nasm bootfile.asm -f bin -o ../../disc_data/bootfile.do
cd /build/src/kernel && nasm kernel.asm -f bin -o ../../rc/kernel.bin