org 0x0000
;mov ax, 0x1000  					; set up kernel position
;mov ds, ax
;mov es, ax

call nano_io_initTextMode
call nano_showStartupInfo

nanoOS:
	
	call nano_showPromt				; show prompt
	call nano_io_readLine			; read command line

	call nano_interpretCommand		; interprete command

	jmp nanoOS						; loop

jmp endOfKernel
%include 'how.asm'
%include 'nano.asm'
%include 'io.asm'
%include 'data.asm'
endOfKernel:


