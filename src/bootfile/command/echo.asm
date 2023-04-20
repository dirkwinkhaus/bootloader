command_echo:
    mov si, cli_io_readLine_buffer
	mov di, command_echo.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end

	.help: db 'sample of use:', 0x0D, 0x0A, 'print something', 0
	.command: db 'echo', 0

	.program:
		mov di, cmd_parameter_1
		mov si, str_parameter_help
		call cli_io_compareStrings
		jc .display_help

		mov si, cmd_parameter_1
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine

		; ###########

	.display_help:
		mov si, .help
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine
		jmp .finish

	.finish:
		jmp command_line_interface.input

	.end:

