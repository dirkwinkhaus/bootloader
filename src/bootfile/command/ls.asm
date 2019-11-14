jmp command_ls
;%include '..\interfaces\iso9660\iso9660_controller.asm';
;%include '..\interfaces\iso9660\iso9660_data_structure.asm';
;%include '..\interfaces\iso9660\iso9660_rom_structure.asm';


command_ls:
    mov si, cli_io_readLine_buffer
	mov di, command_ls.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end


	.help: db 'sample of use:', 0x0D, 0x0A, 'about', 0
	.command: db 'ls', 0
	.output: db 'listing files...', 0

	.program:

        mov si, .output
        call cli_io_printString
        call cli_io_newLine

        jmp command_line_interface.input

	.end:
