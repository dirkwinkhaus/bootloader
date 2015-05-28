org 0x0000
jmp codeBegin
playIntro db 'play loaded...', 0

codeBegin:
call nano_io_initTextMode
mov si, playIntro
call nano_io_printString

mov ah, 00
int 0x16	


jmp endOfKernel
%include 'nanoOS\nano.asm'
%include 'nanoOS\io.asm'
%include 'nanoOS\data.asm'
endOfKernel:
	pop ax
	mov ax, 0x0000
	mov es, ax
	mov ds, ax
	jmp 0x000:0x7c00


