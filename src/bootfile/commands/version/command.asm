command_version:
	.help: db 'sample of use:', 0x0D, 0x0A, 'version', 0
	.command: db 'exit', 0

	.program:
		mov si, str_kernel_kernel
		call cli_io_printString
		mov si, str_kernel_version
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine

		jmp command_line_interface.input

