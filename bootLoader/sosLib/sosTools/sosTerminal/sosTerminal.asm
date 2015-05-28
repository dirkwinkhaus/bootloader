jmp sos_terminal
sosTerminal:
	.version:			db '0.0.1', 0
	.prompt:			db '>>', 0
	.welcome:			db 'sos loaded', 0

sos_terminal:

	
	
	ret