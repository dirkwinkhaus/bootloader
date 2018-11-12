org 0x7C00                                      ; setup start address 
jmp loadLibraries                               ; load library in 2nd sector
version                     db 1, '0.0.7', 2
boot_drive_id 				db 0				; boot drive id

start:
    mov ah, 0x0B                                ; clears whole screen
    mov dl, 14                                  ; foreground
    mov dh, 1                                   ; background
    int 0x81

    jmp start;
    
    jmp $                                       ; stay here

    times 2046-($-$$) db 0                      ; fill rest with 0 to fill sector
    dw 0xAA55                                   ; end of boot sector
    
loadLibraries:
    mov [boot_drive_id], dl                     ; save boot drive id
    %include 'interrupts\sosInt81.asm'          ; loads interrupt 81h
    %include 'interrupts\sosInt90.asm'          ; loads interrupt 81h

    ; include other dependencies here
    jmp start
