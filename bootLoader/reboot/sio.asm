;io.asm main part of nanoOS

; init text mode
nano_io_initTextMode:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	ret


; inserts a cr/lf in text mode
nano_io_newLine:
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A			
	int 0x10				
	ret

	
; waits for key pressed
nano_io_waitForKey:
	mov ah, 0x00
	int 0x16
	ret

; prints a string from si
nano_io_printString:
	lodsb        			

	or al, al  				
	jz .done_printString   	

	mov ah, 0x0E
	int 0x10      			

	jmp nano_io_printString

	.done_printString:
	ret

