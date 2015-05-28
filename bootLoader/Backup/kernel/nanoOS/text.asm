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

	cmp ah, 0x04
	je .textOperation_drawByteAsInt

	cmp ah, 0x05
	je .textOperation_drawByteAsHex

	cmp ah, 0x06
	je .textOperation_drawByteAsBin

	cmp ah, 0x07
	je .textOperation_emptyScreenBuffer

	
	jmp .textOperation_end
;===========================================================================================
	;mov ah, 0x07	; empties screen buffer from position bx, cx in direction dl (0=left /1=right) by length al
	;mov al, 8		; by 8
	;mov dl, 0		; to the left
	;mov bx, 10 		; x
	;mov cx, 4 		; y
	.textOperation_emptyScreenBuffer:
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
		mov ax, 160				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop dx
		pop ax					; restore legnth
		mov ah, 0				; delete ah
		mov cx, ax
		.textOperation_emptyScreenBuffer_output:

			mov byte [es:bx], 0		; set 0
			mov byte [es:bx + 1], 0; set color information 0
			
			cmp dl, 0
			jne .textOperation_emptyScreenBuffer_goRight
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			jmp .textOperation_emptyScreenBuffer_goOn
			.textOperation_emptyScreenBuffer_goRight:
			inc bx					; decrement index of video offset by 2 because color info
			inc bx
			.textOperation_emptyScreenBuffer_goOn:
			
			mov al, ah				; get rest in al to allow looping
			
			dec cx
			
			or cx, cx				; all characters printed?
			jnz .textOperation_emptyScreenBuffer_output
			
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end

	;mov ah, 0x06	; daw byte as hex
	;mov al, 123
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 5 		; x
	;mov cx, 3 		; y
	.textOperation_drawByteAsBin:
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
		mov ax, 160				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop dx
		pop ax					; restore charachter
		mov cx, bx
		.textOperation_drawByteAsBin_output:
			push dx				; save color
			mov ah, 0			; only al will stay
			mov dl, 2			; which base2
			div dl				; divide
			mov dl, ah			; get quotation
			mov ah, al			; save result in ah
			add dl, '0'			; add 0 to result to get right ascii nb
			mov al, dl			; get char in al
			pop dx				; restore color
			mov byte [es:bx], al	; draw charachter
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			mov al, ah				; get rest in al to allow looping
			or al, al				; all characters printed?
			jnz .textOperation_drawByteAsBin_output
			
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end


	;mov ah, 0x05	; daw byte as hex
	;mov al, 123
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 5 		; x
	;mov cx, 3 		; y
	.textOperation_drawByteAsHex:
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
		mov ax, 160				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop dx
		pop ax					; restore charachter
		mov cx, bx
		.textOperation_drawByteAsHex_output:
			push dx				; save color
			mov ah, 0			; only al will stay
			mov dl, 16			; which base16
			div dl				; divide
			mov dl, ah			; get quotation
			mov ah, al			; save result in ah
			add dl, '0'			; add 0 to result to get right ascii nb
			
			cmp dl, '9'
			jle .textOperation_drawByteAsHex_below9
			add dl, 7	
			.textOperation_drawByteAsHex_below9:
			mov al, dl			; get char in al
			pop dx				; restore color
			mov byte [es:bx], al	; draw charachter
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			mov al, ah				; get rest in al to allow looping
			or al, al				; all characters printed?
			jnz .textOperation_drawByteAsHex_output
			
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end


	;mov ah, 0x04	; daw byte as int
	;mov al, 123
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 5 		; x
	;mov cx, 2 		; y
	.textOperation_drawByteAsInt:
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
		mov ax, 160				; set line width in ax
		mul bx					; multiply line width with y
		pop bx					; get x
		add ax, bx				; add x to result to get the final offset
		mov bx, ax				; store result in bx
		pop dx
		pop ax					; restore charachter
		mov cx, bx
		.textOperation_drawByteAsInt_output:
			push dx				; save color
			mov ah, 0			; only al will stay
			mov dl, 10			; which base10
			div dl				; divide
			mov dl, ah			; get quotation
			mov ah, al			; save result in ah
			add dl, '0'			; add 0 to result to get right ascii nb
			mov al, dl			; get char in al
			pop dx				; restore color
			mov byte [es:bx], al	; draw charachter
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			mov al, ah				; get rest in al to allow looping
			or al, al				; all characters printed?
			jnz .textOperation_drawByteAsInt_output
			
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end

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
		mov ax, 160				; set line width in ax
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
