; init interrupts
push es
push bx

;INIT INT100h---------------------------------------------------
mov bx, 0
mov es, bx

mov dx, VGA_13_graphOperations 
mov [es:0xA0*4], dx 
mov ax, cs 
mov [es:0xA0*4+2], ax 
;--------------------------------------------------------------
pop bx
pop es

;====================================================================================================

jmp graphEnd

VGA_13_graphOperations:
	cmp ah, 0x00							; function 0x00 init vga 13 
	je .VGA_13_graphOperations_initVGA13

	cmp ah, 0x01							; function 0x01 set color register
	je .VGA_13_graphOperations_setColorRegister

	cmp ah, 0x0A							; function 0x0A for draw point
	je .VGA_13_graphOperations_drawPoint

	
	jmp .VGA_13_graphOperations_end

	;mov ah, 0x00	;function
	;int 0xA0
	.VGA_13_graphOperations_initVGA13:	
		mov ah, 0x0				; function 
		mov al, 0x13			; mode
		int 0x10				; get vga mode 13
		jmp .VGA_13_graphOperations_end

	;mov ah, 0x01	; function 
	;mov al, 0		; color to change
	;mov bh, 0xff	; red
	;mov bl, 0x0f	; red
	;mov ch, 0x0f	; red
	;int 0xA0
	.VGA_13_graphOperations_setColorRegister:
		push ax
		mov ax, 0x03C8 			; Set the port number to 03C8h
		mov dx, ax				; setup dx
		pop ax
		out dx, al    			; Tell the VGA card that we want to change color 0
		inc dx       			; Set the port number to 03C9h
		mov al, bh
		out dx, al   			; Set red component to 63
		mov al, bl
		out dx, al   			; Set red component to 63
		mov al, ch
		out dx, al   			; Set red component to 63
		jmp .VGA_13_graphOperations_end
	
	
	;mov ah, 0x0A	; mode draw point
	;mov al, 12		; color
	;mov bx, 10 	; x
	;mov cx, 100 	; y
	;int 0xA0		
	.VGA_13_graphOperations_drawPoint:
		push es					; save es register
		push ax					; save ax register 	(mode/color)
		push bx					; save bx register	(X)
		push cx					; save cx register	(Y)
		mov bx, 0xA000			; load port 0xa000 VGA Port 320x200 mode 0x13
		mov es, bx				; setup
		pop cx					; get y
		mov bx, cx				; mov y to bx for multiplying
;		mov cx, bx				; save x in cx
		mov ax, 320				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop ax					; restore color
		mov byte [es:bx], al	; draw point
		pop es					; restore es
		jmp .VGA_13_graphOperations_end
		
	.VGA_13_graphOperations_end:
	iret 	
	
graphEnd: