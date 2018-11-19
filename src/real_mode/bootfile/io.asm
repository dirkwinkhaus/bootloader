; init text mode
cli_io_initTextMode:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	ret


; inserts a cr/lf in text mode
cli_io_newLine:
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A			
	int 0x10				
	ret

	
; waits for key pressed
cli_io_waitForKey:
	mov ah, 0x00
	int 0x16
	ret

; prints a string from si
cli_io_printString:
	lodsb        			

	or al, al  				
	jz .done_printString   	

	mov ah, 0x0E
	int 0x10      			

	jmp cli_io_printString

	.done_printString:
	ret


;mov si, a_string_label
;mov dl, 14		; foreground
;mov dh, 1		; background
;mov bx, 5 		; x
;mov cx, 3 		; y
cli_io_print_string_as_hex:
	.loop:
	xor ax, ax
	mov al, byte [si]
	int 0x81
	add bx, 2
	inc si
	cmp al, 0
	jne .loop

	ret



; read keys until return and saves them in di
cli_io_readLine:
	mov di, cli_io_readLine_buffer
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
cli_io_copyString:
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
	
		
cli_io_clearParameterData:
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
cli_io_compareStrings:
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
cli_io_compareStringsTillSpace:
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
		call cli_io_clearParameterData
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
		call cli_io_clearParameterData
		
		lodsb       						; get space away 			
		mov di, cmd_parameter_1				; store in cmdParameter_x
		call cli_io_copyString				; copy to cmdParameter_x
		jnc .part_done						; if no ending space go to end else read next parameter
		mov di, cmd_parameter_2				; store in cmdParameter_x
		call cli_io_copyString				; copy to cmdParameter_x
		jnc .part_done						; if no ending space go to end else read next parameter
		mov di, cmd_parameter_3				; store in cmdParameter_x
		call cli_io_copyString				; copy to cmdParameter_x
		jnc .part_done						; if no ending space go to end else read next parameter
		
		jmp .part_done
		
	.part_done: 	
		stc  								; equal, set the carry flag
		ret									; jump to calling point

;cli kernel functions

; show debug info
cli_debug:
	mov si, str_kernel_debug
	call cli_io_printString
	ret


; shows startup info
cli_showStartupInfo:
	mov si, str_kernel_kernel
	call cli_io_printString
	mov si, str_kernel_version
	call cli_io_printString
	mov si, str_kernel_loaded
	call cli_io_printString
	ret


; draws prompt
cli_showPromt:
	mov si, str_command_prompt
	call cli_io_printString
	ret
