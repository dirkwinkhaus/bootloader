command_version:
	mov di, command_version.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end


	.help: db 'sample of use:', 0x0D, 0x0A, 'version', 0
	.command: db 'version', 0

	.program:
		mov si, str_kernel_kernel
		call cli_io_printString
		mov si, str_kernel_version
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine

		jmp command_line_interface.input

	.end:

