command_line_interface:

	call cli_io_initTextMode
	call cli_showStartupInfo

	.input:

		call cli_showPromt				; show prompt
		call cli_io_readLine			; read command line

		.cli_interpretCommand:
			%include 'commands.asm'

			cli_commandNotFound:
				mov si, str_command_commandNotFound
				call cli_io_printString
				call cli_io_newLine
				jmp command_line_interface.input

		jmp command_line_interface.input

	%include 'io.asm'
	%include 'data.asm'

	ret

