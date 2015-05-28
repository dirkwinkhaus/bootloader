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


; read keys until return and saves them in di
nano_io_readLine:
	mov di, nano_io_readLine_buffer
	xor cl, cl
	.part_loop:
		mov ah, 0
		int 0x16   				; wait for keypress

		cmp al, 0x08    		; backspace pressed?
		je .part_backspace   	; goto backspace handler

		cmp al, 0x0D  			; enter pressed?
		je .part_done      		; finished input string

		cmp cl, 0x3f  			; 63 chars inputted?
		je .part_loop      		; yes, only let in backspace and enter

		mov ah, 0x0E
		mov bh, 0x0
		mov bl, 0x11
		int 0x10      			; print out character from al

		stosb  					; save al to ES:(E)DI
		inc cl					; inc char counter
		jmp .part_loop			; next

	.part_backspace:
		cmp cl, 0				; if no character in string 
		je .part_loop			; do nothing

		dec di					; dec di index by 1
		mov byte [di], 0		; delete character
		dec cl					; decrement counter

		mov ah, 0x0E			; ouput mode fo int 0x10
		mov al, 0x08			; backspace on the screen
		int 10h					

		mov al, ' '				; blank character out (ah is still 0x0e)
		int 10h					

		mov al, 0x08			; backspace again
		int 10h					

		jmp .part_loop			

	.part_done:
		mov al, 0				; insert null to stosb as terminator
		stosb					; save null

		mov ah, 0x0E
		mov al, 0x0D
		int 0x10
		
		mov al, 0x0A			; newline
		int 0x10				

		ret


; copies a string to a buffer // until space or 0
nano_io_copyString:
	.part_loop:
		lodsb       						; load byte from si in al 			
		cmp al, 0x20						; space?
		je .endingSpace
		stosb								; store al in di
		or al, al  							; if 0 end
		jnz .part_loop
		ret
		.endingSpace:
			mov al, 0x00
			stosb							; save ending 0
			stc								; set carry flag
			ret
	
		
nano_io_clearParameterData:
	; clear parameter
	mov di, cmd_parameter_1
	mov al, 0x00						; insert 0 to di
	stosb
	mov di, cmd_parameter_2
	mov al, 0x00						; insert 0 to di
	stosb
	mov di, cmd_parameter_3
	mov al, 0x00						; insert 0 to di
	stosb
	ret
		

; compares strings from si and di 
nano_io_compareStrings:
	.part_loop:
		mov al, [si]						; inserted command "howtt"
		mov bl, [di]    					; command to compare "howto"

		cmp al, bl     						; compare byte from si and di
		jne .part_notEqual  				; if not equal goto notequal

		cmp al, 0  							; 0 terminates the string and the comparison
		je .part_done   							

		inc di     							; increment index of DI
		inc si     							; increment index of SI
		jmp .part_loop  					; loop!

	.part_notEqual:
		mov cx, 0
		clc  								; not equal, clear the carry flag
		ret									; jump to calling point
		
	.part_done: 	
		stc  								; equal, set the carry flag
		ret									; jump to calling point


;compares strings from si and di till space for command comparison and parameters
nano_io_compareStringsTillSpace:
	.part_loop:
		mov al, [si]						; inserted command "howtt"
		mov bl, [di]    					; command to compare "howto"

		cmp al, bl     						; compare byte from si and di
		jne .part_notEqual  				; if not equal goto notequal

		cmp al, 0  							; 0 terminates the string and the comparison
		je .part_doneClearParameter   							

		inc di     							; increment index of DI
		inc si     							; increment index of SI
		jmp .part_loop  					; loop!

	.part_doneClearParameter:
		call nano_io_clearParameterData
		jmp .part_done

	.part_notEqual:
		mov cx, 0
		cmp bl, 0							; if command to compare is not terminated with 0 now
		jne .part_notEqual_noEndingSpace	; it is not equal
		cmp al, 0x20 						; if inserted command with ending space it is ok
		je .part_parameter 					; get parameters
		
		.part_notEqual_noEndingSpace:
			clc  								; not equal, clear the carry flag
			ret									; jump to calling point

	.part_parameter:		
		call nano_io_clearParameterData
		
		lodsb       						; get space away 			
		mov di, cmd_parameter_1				; store in cmdParameter_x
		call nano_io_copyString				; copy to cmdParameter_x
		jnc .part_done						; if no ending space go to end else read next parameter
		mov di, cmd_parameter_2				; store in cmdParameter_x
		call nano_io_copyString				; copy to cmdParameter_x
		jnc .part_done						; if no ending space go to end else read next parameter
		mov di, cmd_parameter_3				; store in cmdParameter_x
		call nano_io_copyString				; copy to cmdParameter_x
		jnc .part_done						; if no ending space go to end else read next parameter
		
		jmp .part_done
		
	.part_done: 	
		stc  								; equal, set the carry flag
		ret									; jump to calling point


; Input:
; ESI = pointer to the string to convert
; ECX = number of digits in the string (must be > 0)
; Output:
; EAX = integer value
nano_io_stringToInt:
  xor ebx,ebx    				; clear ebx
.next_digit:
  movzx eax,byte[esi]
  inc esi
  sub al,'0'    				; convert from ASCII to number
  imul ebx,10
  add ebx,eax   				; ebx = ebx*10 + eax
  loop .next_digit  			; while (--ecx)
  mov eax,ebx
  ret


; Input:
; EAX = integer value to convert
; ESI = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; EAX = pointer to the first character of the generated string
nano_io_intToString:
  add si,9
  mov byte [si],0 				; add terminating 0

  mov ebx,10         
.next_digit:
  xor edx,edx         			; Clear edx prior to dividing edx:eax by ebx
  div ebx             			; eax /= 10
  add dl,'0'          			; Convert the remainder to ASCII 
  dec si             			; store characters in reverse order
  mov [si],dl
  test eax,eax            
  jnz .next_digit     			; Repeat until eax==0
  mov eax,esi
  ret

  
	
;mov byte[nano_io_intToStr_int], CDDriveNumber
;mov word[nano_io_intToStr_base], 10
;mov byte[nano_io_intToStr_length], 10
;call nano_io_intToStr
nano_io_intToStr:
	push ax								; store registers
	push bx
	push cx
	
	mov ah, 0x03						; get cursor positioning
	mov bh, 0
	int 0x10
	mov ah, dh
	
	mov dh, 0
	add dl, [nano_io_intToStr_length]	; add cursor x by str length
	push dx								; save dx with position
	
	mov dh, ah
	mov ah, 0x02
	mov bh, 0
	int 0x10

	.nano_io_intToStr_loop:

		mov ax, [nano_io_intToStr_int]			; get value
		mov dl, [nano_io_intToStr_base]			; which base?
		div dl
		mov [nano_io_intToStr_int], al
		mov dl, ah
		add dl, '0'

		mov ah, 0x09							; write char
		mov bh, 0
		mov cx, 1
		mov bl, 29
		mov al, dl
		int 0x10

		mov ah, 0x03							; get cursor position
		mov bh, 0
		int 0x10
		
		sub dl, 1								; position of cursor 1 left
		mov ah, 0x02
		mov bh, 0
		int 0x10
		
		cmp word[nano_io_intToStr_int], 0		; all characters printed?
		jne .nano_io_intToStr_loop

	mov ah, 0x02								; set cursor to end of line
	pop dx
	add dl, 1
	mov bh, 0
	int 0x10
		
	pop cx
	pop bx
	pop ax
	ret

;mov byte[nano_io_intToStr_int], 255
;call nano_io_intToHex
nano_io_intToHex:
	push ax								; store registers
	push bx
	push cx
	
	mov ah, 0x03						; get cursor positioning
	mov bh, 0
	int 0x10
	mov ah, dh
	
	mov dh, 0
	add dl, 3							; add cursor x by str length in this case 3 => byte to hex
	push dx								; save dx with position
	
	mov dh, ah
	mov ah, 0x02
	mov bh, 0
	int 0x10

	.nano_io_intToHex_loop:

		mov ax, [nano_io_intToStr_int]			; get value
		mov dl, 16								; which base?
		div dl
		mov [nano_io_intToStr_int], al
		mov dl, ah
		add dl, '0'

		mov ah, 0x09							; write char
		mov bh, 0
		mov cx, 1
		mov bl, 29
		mov al, dl
		
		cmp al, 0x3a
		jl .echoCharacter
		
		add al, 7
		
		.echoCharacter:
		int 0x10

		mov ah, 0x03							; get cursor position
		mov bh, 0
		int 0x10
		
		sub dl, 1								; position of cursor 1 left
		mov ah, 0x02
		mov bh, 0
		int 0x10
		
		cmp word[nano_io_intToStr_int], 0		; all characters printed?
		jne .nano_io_intToHex_loop

	mov ah, 0x02								; set cursor to end of line
	pop dx
	add dl, 1
	mov bh, 0
	int 0x10
		
	pop cx
	pop bx
	pop ax
	ret

