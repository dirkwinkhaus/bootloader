command_line_interface:

	call cli_io_initTextMode
	call cli_showStartupInfo

	.input:

		call cli_showPromt				; show prompt
		call cli_io_readLine			; read command line

		; interpretes a command in si
		.cli_interpretCommand:

			; is the command nothing?
			mov si, cli_io_readLine_buffer
			mov di, cmd_noCommand
			call cli_io_compareStringsTillSpace
			jc command_line_interface.input

			%include 'commands\commands.asm'

			; shows info command not found
			cli_commandNotFound:
				mov si, str_command_commandNotFound
				call cli_io_printString
				call cli_io_newLine
				jmp command_line_interface.input

		jmp command_line_interface.input

	%include 'io.asm'
	%include 'data.asm'

	ret

