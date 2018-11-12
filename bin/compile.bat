#@echo off
cd ..\src\core

@echo create binary core file
nasm core.asm -f bin -o ..\..\rc\core.bin 
if errorlevel 1 goto display_error
goto create_disc
:display_error
pause
goto end_of_file
:create_disc
del ..\..\rc\preOS.iso
ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile ..\..\rc\core.bin -output ..\..\rc\preOS.iso -file ..\..\disc_data\file-a.txt -file ..\..\disc_data\file-b.txt -file ..\..\disc_data\filec.txt -file ..\..\disc_data\terminal.do -file ..\..\disc_data\reboot.do -directory ..\..\disc_data\directory
:end_of_file
cd ..\..\bin