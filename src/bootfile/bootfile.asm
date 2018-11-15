org 0x0000
;mov ax, 0x1000  					; set up kernel position
;mov ds, ax
;mov es, ax

jmp boot

dependencies:
	%include 'cli.asm'

boot:
	call command_line_interface
