; init interrupts
push es
push bx

;INIT INT100h---------------------------------------------------
mov bx, 0
mov es, bx

mov dx, textOperation 
mov [es:0x81*4], dx 
mov ax, cs 
mov [es:0x81*4+2], ax 
;--------------------------------------------------------------
pop bx
pop es

;====================================================================================================

jmp textEnd

; 	nr		function
;	00h		init text mode
;	01h		read char
;	02h		write char
textOperation:
	cli

	cmp ah, 0x00					
	je .textOperation_initTextMode

	cmp ah, 0x01
	je .textOperation_readChar

	cmp ah, 0x02
	je .textOperation_writeChar

	cmp ah, 0x03
	je .textOperation_writeString

	
	jmp .textOperation_end
;===========================================================================================

	;mov ah, 0x03	; daw string
	;mov si, str_kernel_debug
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 1 		; x
	;mov cx, 1 		; y
	.textOperation_writeString:
		push es					; save es register
		push ax					; save ax register 	(mode)
		push dx					; save dx register (color)
		mov ax, 2				; multiply by 2
		mul bx					; get right coordinate
		mov bx, ax				; get result in bx
		push bx					; save bx register	(X)
		push cx					; save cx register	(Y)
		mov bx, 0xB800			; load port 
		mov es, bx				; setup
		pop cx					; get y
		mov bx, cx				; mov y to bx for multiplying
		mov ax, 80				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop dx
		pop ax					; restore charachter

		mov cx, bx
		.textOperation_writeString_writeText:
			lodsb 
			or al, al  				
			jz .textOperation_writeString_endWriteText   
			mov byte [es:bx], al	; draw charachter
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information

			inc bx
			inc bx
			jmp .textOperation_writeString_writeText
			
		.textOperation_writeString_endWriteText:
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end
	
	
;	mov ah, 0x02	; daw charachter
;	mov al, 205		; char
;	mov dl, 14		; foreground
;	mov dh, 1		; background
;	mov bx, 10 		; x
;	mov cx, 10 		; y
	.textOperation_writeChar:
		push es					; save es register
		push ax					; save ax register 	(mode)
		push dx					; save dx register (color)
		mov ax, 2				; multiply by 2
		mul bx					; get right coordinate
		mov bx, ax				; get result in bx
		push bx					; save bx register	(X)
		push cx					; save cx register	(Y)
		mov bx, 0xB800			; load port 
		mov es, bx				; setup
		pop cx					; get y
		mov bx, cx				; mov y to bx for multiplying
		mov ax, 80				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop dx
		pop ax					; restore charachter
		mov byte [es:bx], al	; draw charachter
		push ax					; save charachter and function
		mov al, dh				; mov background color to al
		shl al, 4				; shift 4 bits left to set background
		or al, dl				; combine fore and background color
		mov byte [es:bx + 1], al; set color information
		pop ax					; get charchter and function back
		pop es					; restore es
		jmp .textOperation_end
	
	;mov ah, 0x81	; draw charachter
	;mov bx, 10 	; x
	;mov cx, 10 	; y
	;returns char in al
	.textOperation_readChar:
		push es					; save es register
		push bx					; save bx register	(X)
		push cx					; save cx register	(Y)
		mov bx, 0xB800			; load port
		mov es, bx				; setup
		pop cx					; get y
		mov bx, cx				; mov y to bx for multiplying
;		mov cx, bx				; save x in cx
		mov ax, 80				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		mov al, byte [es:bx]	; draw point
		pop es					; restore es
		jmp .textOperation_end
	
	.textOperation_initTextMode:
		mov ah, 0x0				; function 
		mov al, 0x3				; mode
		int 0x10				; get vga mode 3
		jmp .textOperation_end
	
	.textOperation_end:
	sti
	iret


textEnd:
