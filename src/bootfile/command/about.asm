command_about:
    mov si, cli_io_readLine_buffer
	mov di, command_about.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end

	.help: db 'sample of use:', 0x0D, 0x0A, 'about', 0
	.command: db 'about', 0

	.program:

        mov si, str_kernel_about
        call cli_io_printString
        call cli_io_newLine

        jmp command_line_interface.input

	.end:
