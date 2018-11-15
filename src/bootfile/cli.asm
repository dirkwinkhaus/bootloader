command_line_interface:

	call cli_io_initTextMode
	call cli_showStartupInfo

	.input:

		call cli_showPromt				; show prompt
		call cli_io_readLine			; read command line

		; interpretes a command in si
		.cli_interpretCommand:
			mov si, cli_io_readLine_buffer

			; is the command nothing?
			mov di, cmd_noCommand
			call cli_io_compareStringsTillSpace
			jc command_line_interface.input

			; is the command nothing?
			mov di, command_exit.command
			call cli_io_compareStringsTillSpace
			jc command_exit.command

			; is the command about?
			mov di, command_about.command
			call cli_io_compareStringsTillSpace
			jc command_about.command

			; is the command version?
			mov di, command_version.command
			call cli_io_compareStringsTillSpace
			jc command_version.program

			; is the command version?
			mov di, command_reboot.command
			call cli_io_compareStringsTillSpace
			jc command_reboot.program

			; is the command how?
			mov di, command_how.command
			call cli_io_compareStringsTillSpace
			jc command_how.program

			; shows info command not found
			cli_commandNotFound:
				mov si, str_command_commandNotFound
				call cli_io_printString
				call cli_io_newLine
				jmp command_line_interface.input

		jmp command_line_interface.input

	jmp endOfKernel
	%include 'io.asm'
	%include 'data.asm'
	%include 'commands\commands.asm'

	endOfKernel:
	ret

