command_how:
	.help: db 'sample of use:', 0x0D, 0x0A, 'how [e.g. exit|version|reboot]', 0
	.command: db 'how', 0
	.no_help: db 'no help found for this command', 0

	.program:
		; version command
		mov si, cmd_parameter_1
		mov di, command_version.command
		call cli_io_compareStrings
		jc .command_version

		; about command
		mov si, cmd_parameter_1
		mov di, command_about.command
		call cli_io_compareStrings
		jc .command_about

		; reboot command
		mov si, cmd_parameter_1
		mov di, command_reboot.command
		call cli_io_compareStrings
		jc .command_reboot

		; reboot command
		mov si, cmd_parameter_1
		mov di, command_exit.command
		call cli_io_compareStrings
		jc .command_exit

		; nothing found
		jmp .command_done_notFound

		.command_version:
			mov si, command_version.help
			call cli_io_printString
			jmp .command_done

		.command_about:
			mov si, command_how.help
			call cli_io_printString
			jmp .command_done

		.command_reboot:
			mov si, command_reboot.help
			call cli_io_printString
			jmp .command_done

		.command_exit:
			mov si, command_exit.help
			call cli_io_printString
			jmp .command_done

		.command_done_notFound:
			mov si, command_how.no_help
			call cli_io_printString

		.command_done:
			call cli_io_newLine
			call cli_io_newLine

		jmp command_line_interface.input

