command_reboot:
	mov di, command_reboot.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end

	.help: db 'sample of use:', 0x0D, 0x0A, 'reboot', 0
	.command: db 'reboot', 0

	.program:
		mov di, cmd_parameter_1
		mov si, str_parameter_help
		call cli_io_compareStrings
		jc .display_help

		; store magic value at 0040h:0072h to reboot:
		;		0000h - cold boot.
		;		1234h - warm boot.
		MOV  AX,0040h
		MOV  DS,AX
		MOV  word[0072h],0000h
		JMP  0FFFFh:0000h

	.display_help:
		mov si, .help
		call cli_io_printString
		call cli_io_newLine
		call cli_io_newLine
		jmp .end

	.end: