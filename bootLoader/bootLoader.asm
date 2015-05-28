org 0x7C00									; setup start address 
jmp loadLibraries							; load library in 2nd sector
db 1, '0.0.7', 2

startOfCode:
	mov ah, 0x0B	; clears whole screen
	mov dl, 14		; foreground
	mov dh, 1		; background
	int 0x81

	call sos_Commander
	
	jmp $										; halt here

	times 2046-($-$$) db 0 						; fill rest with 0 to fill sector
	dw 0xAA55									;end of boot sector
	; end of first sector


	
loadLibraries:
	%include 'sosLib\sosLib.asm'							; load sosLib.asm
	jmp startOfCode
