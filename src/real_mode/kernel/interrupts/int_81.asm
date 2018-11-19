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

textOperation:
	cli

	cmp ah, 0x00					
	je .textOperation_initTextMode

	;mov ah, 0x01		; read charachter
	;mov bx, 10 		; x
	;mov cx, 10 		; y
	; return char in al 
	cmp ah, 0x01
	je .textOperation_readChar

	;mov ah, 0x02	; draw charachter
	;mov al, 205		; char
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 10 		; x
	;mov cx, 10 		; y
	cmp ah, 0x02
	je .textOperation_writeChar

	;mov ah, 0x03	; draw string
	;mov si, str_kernel_debug
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 1 		; x
	;mov cx, 1 		; y
	cmp ah, 0x03
	je .textOperation_writeString

	;mov ah, 0x04	; draw byte as int
	;mov al, 123
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 5 		; x
	;mov cx, 2 		; y
	cmp ah, 0x04
	je .textOperation_drawByteAsInt

	;mov ah, 0x05	; draw byte as hex
	;mov al, 123
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 5 		; x
	;mov cx, 3 		; y
	cmp ah, 0x05
	je .textOperation_drawByteAsHex

	;mov ah, 0x06	; draw byte as hex
	;mov al, 123
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 5 		; x
	;mov cx, 3 		; y
	cmp ah, 0x06
	je .textOperation_drawByteAsBin

	;mov ah, 0x07	; empties screen buffer from position bx, cx in direction dl (0=left /1=right) by length al
	;mov al, 8		; by 8
	;mov dl, 0		; to the left
	;mov dh, 1		; background color
	;mov bx, 10 		; x
	;mov cx, 4 		; y
	cmp ah, 0x07
	je .textOperation_emptyScreenBuffer

	;mov ah, 0x08	; function
	;mov bx, 0x0000	;segment
	;mov cx, 0x7C00	;offset
	;mov dl, 14		; foreground color
	;mov dh, 1		; background color
	cmp ah, 0x08
	je .textOperation_printBuffer

	
	;mov ah, 0x03	; draw string by length
	;mov al, 4		; length of string	
	;mov si, str_kernel_debug
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 1 		; x
	;mov cx, 1 		; y
	cmp ah, 0x09
	je .textOperation_writeStringByLength


	;mov ah, 0x0A	; draw part of buffer
	;mov ds, 0x1000 ; set data segment
	;mov si, 0x0000 ; set data offeset
	;mov bh, 5 		; x
	;mov bl, 3 		; y
	;mov cx, 1000	; how many charachters of buffer shown
	cmp ah, 0x0A
	je .textOperation_drawPartOfBuffer ; 

	
	;mov ah, 0x0B	; clears whole screen
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	cmp ah, 0x0B
	je .textOperation_clear
	

	;mov ah, 0x0C	; draw string by length
	;mov al, 4		; how often place attributes
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 1 		; x
	;mov cx, 1 		; y
	cmp ah, 0x0C
	je .textOperation_setAttributeBuffer

	;mov ah, 0x0D	; is string 1 contained by string 2
	;mov si, string_variable_1		; min this string should end with 0
	;mov di, string_variable_2
    ;mov cx, max_comparable_length
	cmp ah, 0x0D
	je .textOperation_compareStrings
	
	jmp .textOperation_end
;===========================================================================================



	;mov ah, 0x0D	; is string 1 contained by string 2
	;mov si, string_variable_1		; min this string should end with 0
	;mov di, string_variable_2
    ;mov cx, max_comparable_length
    .textOperation_compareStrings:
        .textOperation_compareStrings_loop:
            mov ah, [si]
            mov al, [di]
            
            cmp ah, 0
            je .textOperation_compareStrings_equal
            
            cmp ah, al
            jne .textOperation_compareStrings_not_equal
            
            inc si
            inc di
            jmp .textOperation_compareStrings_loop
        
        .textOperation_compareStrings_equal:
        mov al, 1
        jmp .textOperation_end

        .textOperation_compareStrings_not_equal:
        mov al, 0
        jmp .textOperation_end
        
        
    
    
	;mov ah, 0x0C	; draw string by length
	;mov al, 4		; how often place attributes
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 1 		; x
	;mov cx, 1 		; y
	.textOperation_setAttributeBuffer:
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
		mov ah, al				; save count in ah
		mov cx, bx
		.textOperation_setAttributeBuffer_writeText:
			
			or ah, ah
			jz .textOperation_setAttributeBuffer_endWriteText   
			dec ah
			
			.textOperation_setAttributeBuffer_drawByte:
				mov al, dh				; mov background color to al
				shl al, 4				; shift 4 bits left to set background
				or al, dl				; combine fore and background color
				mov byte [es:bx + 1], al; set color information

				inc bx
				inc bx
				jmp .textOperation_setAttributeBuffer_writeText
			
		.textOperation_setAttributeBuffer_endWriteText:
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end


	;mov ah, 0x0B	; clears whole screen
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	.textOperation_clear:
		push es
		mov bx, 0xB800			; load port 
		mov es, bx				; setup
		xor bx, bx
		.textOperation_clear_clearing:
			mov byte [es:bx], 0	; draw charachter
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			inc bx
			inc bx
			cmp bx, 4000
			jl .textOperation_clear_clearing
		pop es					; restore es
		jmp .textOperation_end
	

	;mov ah, 0x0A	; draw part of buffer
	;mov ds, 0x1000 ; set data segment
	;mov si, 0x0000 ; set data offeset
	;mov bh, 5 		; x
	;mov bl, 3 		; y
	;mov cx, 1000	; how many charachters of buffer shown
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	.textOperation_drawPartOfBuffer:
		push ax					; save register
		push es					; save register
		push di					; save register
		
		mov ax, 160				; calculate the position in memory
		mul bl
		
		shr bx, 8				; delete x from bx
		
		add bx, ax
		push ax					; save position
		
		mov bx, 0xB800			; set up video memory
		mov es, bx
		mov di, 0
		
		pop bx
		xor ax, ax				; set bx, 0	

		.textOperation_drawPartOfBuffer_output:
			mov al, [ds:si]
			
			mov byte [es:di + bx], al
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			
			inc bx
			inc bx
			inc si
			dec cx
			or cx, cx 
			jnz .textOperation_drawPartOfBuffer_output

		pop di
		pop es
		pop ax					; restore 
		jmp .textOperation_end


	

	;mov ah, 0x09	; draw string by length
	;mov al, 4		; length of string	
	;mov si, str_kernel_debug
	;mov dl, 14		; foreground
	;mov dh, 1		; background
	;mov bx, 1 		; x
	;mov cx, 1 		; y
	.textOperation_writeStringByLength:
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
		mov ah, al				; save count in ah
		mov cx, bx
		.textOperation_writeStringByLength_writeText:
			lodsb 
			
			or ah, ah
			jz .textOperation_writeStringByLength_endWriteText   
			dec ah
			
			.textOperation_writeStringByLength_drawByte:
				mov byte [es:bx], al	; draw charachter
				mov al, dh				; mov background color to al
				shl al, 4				; shift 4 bits left to set background
				or al, dl				; combine fore and background color
				mov byte [es:bx + 1], al; set color information

				inc bx
				inc bx
				jmp .textOperation_writeStringByLength_writeText
			
		.textOperation_writeStringByLength_endWriteText:
		mov bx, cx
		pop es					; restore es
		jmp .textOperation_end


	;mov ah, 0x08	; function
	;mov bx, 0x0000	;segment
	;mov cx, 0x7C00	;offset
	;mov dl, 14		; foreground color
	;mov dh, 1		; background color
	.textOperation_printBuffer:
		push ax					; save register
		push es					; save register
		push di					; save register
		push ds					; save register
		mov es, bx				; set es segment register
		mov di, cx				; set di offset register
		mov bx, 0xB800			; B800 in text mode
		mov ds, bx				; set up video segment register
		xor bx, bx				; set bx, 0
		xor cx, cx				; set cx, 0
		.textOperation_printBuffer_output:
			push bx				; save screen position
			mov bx, cx			; get counter
			mov al, byte [es:di+bx]; get character
			pop bx				; restore screen position
			mov byte [ds:bx], al; draw character
			inc bx				; next video position
			mov ah, dh			; get background color
			shl ah, 4			; shift 4 bits left
			or ah, dl			; insert foreground color
			mov byte [ds:bx], ah; black background green font
			inc bx				; next video position
			inc cx				; inc counter
			cmp bx, 4000		; whole screen filled? (80*25*2)
			jl .textOperation_printBuffer_output
			
		xor bx, bx
		xor cx, cx
		pop ds					; restore 
		pop di					; restore 
		pop es					; restore 
		pop ax					; restore 
		jmp .textOperation_end

		
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
		push ax
		shl dl, 4
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
		pop ax
		pop es					; restore es
		jmp .textOperation_end

	;mov ah, 0x06	; draw byte as hex
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
		push bx
		mov cx, 8				; max 8 chars
		.textOperation_drawByteAsBin_output:
			push dx					; save color
			mov ah, 0				; only al will stay
			mov dl, 2				; which base2
			div dl					; divide
			mov dl, ah				; get quotation
			mov ah, al				; save result in ah
			add dl, '0'				; add 0 to result to get right ascii nb
			mov al, dl				; get char in al
			pop dx					; restore color
			mov byte [es:bx], al	; draw charachter
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			mov al, ah				; get rest in al to allow looping
			or al, al				; all characters printed?
			dec cx
			jnz .textOperation_drawByteAsBin_output

		.textOperation_drawByteAsBin_filling0:
			cmp cx, 0
			je .textOperation_drawByteAsBin_end
			
			mov byte [es:bx], '0'	; draw 0
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			dec cx
			jmp .textOperation_drawByteAsBin_filling0
		
		.textOperation_drawByteAsBin_end:
			
			
		pop bx
		pop es					; restore es
		jmp .textOperation_end

	;mov ah, 0x05	; draw byte as hex
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
		push bx					; save bx
		mov cx, 2				; set cx, 2 (max 2 chars)
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
			dec cx
			jnz .textOperation_drawByteAsHex_output
		.textOperation_drawByteAsHex_filling0:
			cmp cx, 0
			je .textOperation_drawByteAsHex_end
			
			mov byte [es:bx], '0'	; draw 0
			mov al, dh				; mov background color to al
			shl al, 4				; shift 4 bits left to set background
			or al, dl				; combine fore and background color
			mov byte [es:bx + 1], al; set color information
			dec bx					; decrement index of video offset by 2 because color info
			dec bx
			dec cx
			jmp .textOperation_drawByteAsHex_filling0
		
		.textOperation_drawByteAsHex_end:
		pop bx
		pop es					; restore es
		jmp .textOperation_end


	;mov ah, 0x04	; draw byte as int
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

	;mov ah, 0x03	; draw string
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
			
			.textOperation_writeString_drawByte:
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
	
	
;	mov ah, 0x02	; draw charachter
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
		mov ax, 160				; set line width in ax
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
	
	;mov ah, 0x1	; draw charachter
	;mov bx, 10 	; x
	;mov cx, 10 	; y
	;returns char in al
	.textOperation_readChar:
		push es					; save es register
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
		mov al, byte [es:bx]	; draw point
		pop es					; restore es
		jmp .textOperation_end
	
	.textOperation_initTextMode:
		mov al, 0x3				; mode
		int 0x10				; get vga mode 3
		xor bx, bx 
		mov ax, 1112h 			; trying to get 80x50
		int 10h 
		jmp .textOperation_end
	
	.textOperation_end:
	sti
	iret


textEnd:
