jmp command_ls

;times 5000 db 'a'

%include '../interfaces/iso9660/iso9660_rom_structure.asm';
%include '../interfaces/iso9660/iso9660_data_structure.asm';
%include '../interfaces/iso9660/iso9660_controller.asm';

command_ls:
    mov si, cli_io_readLine_buffer
	mov di, command_ls.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end


	.help: db 'sample of use:', 0x0D, 0x0A, 'about', 0
	.command: db 'ls', 0
	.output: db 'listing files...', 0
	.output2: db 'listing files...dsdddd', 0

	.program:

        mov si, .output
        call cli_io_printString
        call cli_io_newLine

		mov si, .output2
		call cli_io_printString
		call cli_io_newLine

		mov ebx, [iso9660_volumeDescriptor]
		mov es, [iso9660_volumeDescriptor]
		call iso9660_getFirstDirectory
		call iso9660_getNextFile



		.list_files_loop:
			call iso9660_getNextFile
			call iso9660_getFirstFile
			;jc .list_files_loop_end

			; compare kernel file name with found file

			mov si, iso9660_fileDescriptor.fileIdentifier
			call cli_io_printString
			call cli_io_newLine

			jmp .list_files_loop
		.list_files_loop_end:


		; ###########

		jmp .end

        jmp command_line_interface.input

	.end:
