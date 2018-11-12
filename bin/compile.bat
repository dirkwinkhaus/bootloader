@echo off
cd ../bootloader
@echo create binary file
nasm bootloader.asm -f bin -o ../bootloader.bin 
if errorlevel 1 goto display_error
goto create_disc
:display_error
pause
goto end_of_file
:create_disc
del ..\preOS.iso
ultraiso -volume myVolume -sysid mySysId -preparer prepdirk -publisher pubdirk -joliet -bootfile ..\bootLoader.bin -output ..\preOS.iso -file .\cdcontent\file-a.txt -file .\cdcontent\file-b.txt -file .\cdcontent\filec.txt -file .\cdcontent\terminal.do -file .\cdcontent\reboot.do -file .\cdcontent\play.do -directory .\cdcontent\directory
:end_of_file
cd ../bin