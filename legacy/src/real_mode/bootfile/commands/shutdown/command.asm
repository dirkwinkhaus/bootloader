command_shutdown:
	mov di, command_shutdown.command
	call cli_io_compareStringsTillSpace
	jc .program
	jmp .end

	.help: db 'sample of use:', 0x0D, 0x0A, 'shutdown', 0
	.command: db 'shutdown', 0

	.program:
		mov ax, 0x5301
		xor bx, bx
		int 0x15

		mov ax, 0x530f
		mov bx, 1
		mov cx, 1
		int 0x15

		mov ax, 0x5307
		mov bx, 1
		mov cx, 3
		int 0x15

	.end: