command_exit:
	.help: db 'sample of use:', 0x0D, 0x0A, 'exit', 0
	.command: db 'exit', 0

	.program:
	pop ax
	mov ax, 0x0000
	mov es, ax
	mov ds, ax
	jmp 0x000:0x7c00