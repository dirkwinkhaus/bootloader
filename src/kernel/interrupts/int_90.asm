; init interrupts
push es
push bx
push ax

;INIT INT90h---------------------------------------------------
mov bx, 0
mov es, bx

mov dx, executionController 
mov [es:0x90*4], dx 
mov ax, cs 
mov [es:0x90*4+2], ax 
;--------------------------------------------------------------
pop ax
pop bx
pop es

;====================================================================================================

jmp executionexecutionControllerEnd

executionController:
	cli
	cmp ah, 0x01					
	je .executionexecutionController_loadCode

	cmp ah, 0x02	
	je .executionexecutionController_cleanSegment

	jmp .executionexecutionController_end
;===========================================================================================
	;mov ah, 0x01
	;mov ds, 0x1000 			; set data segment
	;mov si, 0xd000 			; set data offeset
	;mov cx, 2048				; how many bytes
	.executionexecutionController_loadCode:
	push ax					; save register
	push bx
	push es					; save register
	push di					; save register
	mov bx, 0x2000			; setup operation segment
	mov es, bx
	xor bx, bx
	mov di, bx
	.executionexecutionController_loadCode_copyCode:
	mov al, [ds:si + bx]
	mov byte [es:di + bx], al
	dec cx
	inc bx
	cmp cx, 0x0
	jne .executionexecutionController_loadCode_copyCode
	pop di
	pop es
	pop bx
	pop ax		
	jmp .executionexecutionController_end
		
	.executionexecutionController_exitCode:
	mov ax, 0x0000
        mov es, ax
	mov ds, ax
	;jmp 0x0000:0x7c00
	jmp .executionexecutionController_end

	;mov ah, 0x02
	.executionexecutionController_cleanSegment:
		push ax					; save register
		push bx
		push es					; save register
		push di					; save register
		mov bx, 0x1000			; setup operation segment
		mov es, bx
		xor bx, bx
		mov di, bx
		.executionexecutionController_cleanSegment_loop:
				mov byte [es:di + bx], 0
				dec cx
				inc bx
				cmp bx, 0xffff
				jne .executionexecutionController_cleanSegment_loop
		pop di
		pop es
		pop bx
		pop ax		
		jmp .executionexecutionController_end
		
	.executionexecutionController_cleanSegment_exitCode:
		mov ax, 0x0000
		mov es, ax
		mov ds, ax
		jmp .executionexecutionController_end

		.executionexecutionController_end:
	sti
	iret

executionexecutionControllerEnd:
