@echo off
cd ..\src
@echo create binary file
nasm core.asm -f bin -o ..\rc\core.bin 
if errorlevel 1 goto display_error
goto create_disc
:display_error
pause
goto end_of_file
:create_disc
del ..\preOS.iso
ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile ..\rc\core.bin -output ..\rc\preOS.iso -file ..\cdcontent\file-a.txt -file ..\cdcontent\file-b.txt -file ..\cdcontent\filec.txt -file ..\cdcontent\terminal.do -file ..\cdcontent\reboot.do -directory ..\cdcontent\directory
:end_of_file
cd ../bin