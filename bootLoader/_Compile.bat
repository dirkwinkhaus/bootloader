@echo off
nasm %1bootLoader.asm -f bin -o %1../bootLoader.bin 
if errorlevel 1 goto echoError
goto runProgramm
:echoError
pause
goto endOfBatch
:runProgramm
del %1..\preOS.iso
ultraiso -volume myVolume -sysid mySysId -preparer prepdirk -publisher pubdirk -joliet -bootfile ..\bootLoader.bin -output ..\preOS.iso -file .\cdcontent\file-a.txt -file .\cdcontent\file-b.txt -file .\cdcontent\filec.txt -file .\cdcontent\terminal.do -file .\cdcontent\reboot.do -file .\cdcontent\play.do -directory .\cdcontent\directory
qemu-system-i386.exe -cdrom ..\preOS.iso
:endOfBatch