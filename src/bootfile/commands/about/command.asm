command_about:
	.help: db 'sample of use:', 0x0D, 0x0A, 'about', 0
	.command: db 'about', 0

	.program:
	mov si, str_kernel_about
	call cli_io_printString
	call cli_io_newLine

	jmp command_line_interface.input

