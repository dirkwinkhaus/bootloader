org 0x0000
call nano_io_initTextMode

mov si, info
call nano_io_printString

call nano_io_waitForKey

; store magic value at 0040h:0072h to reboot:
;		0000h - cold boot.
;		1234h - warm boot.
MOV  AX,0040h
MOV  DS,AX
MOV  word[0072h],0000h   ; cold boot.
JMP  0FFFFh:0000h	 ; reboot!


%include 'sio.asm'

info db 'press any key to reboot...', 0000h
