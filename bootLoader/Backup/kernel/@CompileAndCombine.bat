@echo off
nasm kernel.asm -f bin -o ../kernel.bin 
copy /b ..\bootLoader.bin + ..\kernel.bin ..\nanoOS.bin
pause
C:\"Program Files (x86)"\Bochs-2.6.6\bochs.exe -f " ..\@nanoOS.bxrc" -q

