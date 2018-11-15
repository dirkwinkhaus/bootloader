org 0x7C00                                      ; setup start address 
jmp load_sys_dependencies                           ; load library in 2nd sector

%include 'kernel_model.asm'

start:
    ; hide cursor
    mov ah, 01
    mov cx, 0x2607
    int 0x10

    mov ah, 0x0B                                ; clears whole screen
    mov dl, 2                                  ; foreground
    mov dh, 0                                   ; background
    int 0x81

	call kernel_find_bootfile

    cmp al, 1
    je boot_file_found

    cmp al, 0
    je boot_file_not_found

    jmp $                                       ; stay here

    times 2046-($-$$) db 0                      ; fill rest with 0 to fill sector
    dw 0xAA55                                   ; end of boot sector
    
load_sys_dependencies:
    mov [kernel.boot_drive_id], dl     ; save boot drive id
    mov [kernel.drive_id], dl     ; set drive id
    %include 'interrupts\sosInt81.asm'          ; loads interrupt 81h
    %include 'interrupts\sosInt90.asm'          ; loads interrupt 81h
    jmp start
    
load_dependencies:
    %include '../interfaces\iso9660\iso9660_rom_structure.asm'
    %include '../interfaces\iso9660\iso9660_data_structure.asm'
    %include '../interfaces\iso9660\iso9660_controller.asm'
    %include 'kernel_transfer_model.asm'
    %include 'print_bootfile_information.asm'
    %include 'kernel_find_bootfile.asm'

; show error info
boot_file_not_found:
    mov ah, 0x03    
    mov si, kernel.boot_file_not_found
    mov dl, 4
    mov dh, 0
    mov bx, 0
    mov cx, 2
    int 0x81 
    
    jmp $
    
; show success info
boot_file_found:
    mov ah, 0x03
    mov si, kernel.boot_file_found
    mov dl, 2
    mov dh, 0
    mov bx, 0
    mov cl, 2
    int 0x81

    call kernel_print_boot_file_information
    
    ; load kernel
    mov dword[iso9660_fileDescriptor.locationOfExtendLBA1], eax
    mov eax, dword [kernel_transfer_model.startingAbsoluteBlock]
    
    mov ah, 0x42										
	mov dl, [kernel.drive_id]							
	mov si, kernel_transfer_model						
	int 0x13

    ;jmp 0x2000:0x0000
    
    ret