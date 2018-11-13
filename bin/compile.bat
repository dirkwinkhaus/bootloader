@echo off
cd ..\src\kernel

@echo create binary kernel
nasm kernel.asm -f bin -o ..\..\rc\kernel.bin 
if errorlevel 1 goto display_error
goto create_disc
:display_error
pause
goto end_of_file
:create_disc
del ..\..\rc\preOS.iso
ultraiso -volume myVolume -sysid mySysId -preparer widi -publisher widi -joliet -bootfile ..\..\rc\kernel.bin -output ..\..\rc\preOS.iso -file ..\..\disc_data\text_file.txt -file ..\..\disc_data\terminal.do -file ..\..\disc_data\reboot.do -directory ..\..\disc_data\directory
:end_of_file
cd ..\..\bin