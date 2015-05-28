initMouse:

	mov ah, 0x2c
	mov al, 0x01
	int 0x15

	; enable mouse
	mov ah, 0xc2
	xor al, al
	mov bh, 0x01
	int 0x15
	jc .mouseError
	
	
	jmp .mouseDone
	
	.mouseError:
	mov si, str_mouse_error
	int 0x80
	
	
	.mouseDone:
	ret
	
	;reset mouse
	
	
	
	
str_mouse_error db 0x0D, 0x0A, 'error enabling mouse!', 0x0D, 0x0A, 0	