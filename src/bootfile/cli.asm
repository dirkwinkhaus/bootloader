command_line_interface:

	call cli_io_initTextMode
	call cli_showStartupInfo

	.input:

		call cli_showPromt				; show prompt
		call cli_io_readLine			; read command line

		call cli_interpretCommand		; interprete command

		jmp .input

	jmp endOfKernel
	%include 'how.asm'
	%include 'io.asm'
	%include 'data.asm'
	endOfKernel:
	ret

