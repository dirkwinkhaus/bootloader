command_reboot:
	.help: db 'sample of use:', 0x0D, 0x0A, 'reboot', 0
	.command: db 'reboot', 0

	.program:
		; store magic value at 0040h:0072h to reboot:
		;		0000h - cold boot.
		;		1234h - warm boot.
		MOV  AX,0040h
		MOV  DS,AX
		MOV  word[0072h],0000h
		JMP  0FFFFh:0000h