command_print:
	mov di, command_print.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end

	.help: db 'sample of use:', 0x0D, 0x0A, 'print something', 0
	.command: db 'print', 0

	.program:
		mov di, cmd_parameter_1
		mov si, str_parameter_help
		call cli_io_compareStrings
		jc .display_help

		mov si, cmd_parameter_1
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine
		jmp .finish

	.display_help:
		mov si, .help
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine
		jmp .finish

	.finish:
		jmp command_line_interface.input

	.end:

