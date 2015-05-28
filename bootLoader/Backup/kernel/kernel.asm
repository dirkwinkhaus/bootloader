mov ax, 0x1000  					; set up kernel position
mov ds, ax
mov es, ax


%include 'nanoOS\graph.asm'
%include 'nanoOS\text.asm'

mov ah, 0x00
int 0x81

mov ah, 0x03	; draw string
mov si, str_kernel_debug
mov dl, 14		; foreground
mov dh, 1		; background
mov bx, 10 		; x
mov cx, 0 		; y
int 0x81

mov ah, 0x04	; draw byte as int
mov al, 123
mov dl, 14		; foreground
mov dh, 1		; background
mov bx, 10 		; x
mov cx, 2 		; y
int 0x81

mov ah, 0x05	; draw byte as hex
mov al, 123
mov dl, 14		; foreground
mov dh, 1		; background
mov bx, 10 		; x
mov cx, 3 		; y
int 0x81


mov ah, 0x06	; draw byte as bin
mov al, 123
mov dl, 14		; foreground
mov dh, 1		; background
mov bx, 10 		; x
mov cx, 4 		; y
int 0x81

mov ah, 0x07	; empties screen buffer from position bx, cx in direction dl (0=left /1=right) by length al
mov al, 8		; by 8
mov dl, 0		; to the left
mov bx, 10 		; x
mov cx, 4 		; y
int 0x81

mov ah, 0x06	; draw byte as bin
mov al, 4
mov dl, 14		; foreground
mov dh, 1		; background
mov bx, 10 		; x
mov cx, 4 		; y
int 0x81



looping:
jmp looping


call nano_io_initTextMode
call nano_showStartupInfo


mov si, str_kernel_kernel
int 0x80


push es

mov bx, 0x40
mov ES, bx
mov DI, 0x10							; equipment list
mov ax, [ES:DI]

pop es


nanoOS:
	call nano_showPromt				; show prompt
	call nano_io_readLine			; read command line
	call nano_interpretCommand		; interprete command
	jmp nanoOS						; loop

jmp endOfKernel
%include 'nanoOS\nano.asm'
%include 'nanoOS\io.asm'
%include 'nanoOS\data.asm'
%include 'nanoOS\mouse.asm'

endOfKernel:

times 6144-($-$$) db 0 				; version 1: 12 sectors * 512 bytes

endOfCode:
