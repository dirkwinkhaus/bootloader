command_nocommand:
    mov si, cli_io_readLine_buffer
	mov di, cmd_noCommand
	call cli_io_compareStringsTillSpace
    jc command_line_interface.input
	.end:
