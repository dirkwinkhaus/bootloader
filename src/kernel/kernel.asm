org 0x7C00                                      ; setup start address 
jmp load_sys_dependencies                           ; load library in 2nd sector

kernel:
    .version db 1, '0.0.7', 2
    .boot_drive_id db 0				; boot drive id
    .drive_id db 0
    .str_boot_lookup_info db 'Looking for boot.do...', 0
    .boot_file_name db 'BOOT.DO', 0
    .boot_file_found db 'Found kernel file.', 0
    .boot_file_not_found db 'Kernel file not found.', 0

start:
    mov ah, 0x0B                                ; clears whole screen
    mov dl, 14                                  ; foreground
    mov dh, 1                                   ; background
    int 0x81

    call find_kernel_file;
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
    %include 'transfer_model.asm'

find_kernel_file:   
    ;print copyright info
    mov ah, 0x03    ; draw string
    mov si, kernel.str_boot_lookup_info
    mov dl, 14        ; foreground
    mov dh, 1        ; background
    mov bx, 0         ; x
    mov cx, 0         ; y
    int 0x81 
    
    call iso9660_getFirstDirectory                                ; load root directory
    call iso9660_getNextFile                                    ; delete directory "."
    .find_kernel_file_loop:
        call iso9660_getNextFile                                
        call iso9660_getFirstFile
        jc .find_kernel_file_loop_end                        ; no file found

        ; compare kernel file name with found file
        mov ah, 0x0D
        mov si, kernel.boot_file_name
        mov di, iso9660_fileDescriptor.fileIdentifier
        mov cx, 0
        int 0x81

        cmp al, 1
        je .find_kernel_file_loop_end
        
        jmp .find_kernel_file_loop
    .find_kernel_file_loop_end:
    
    cmp al, 1
    je .boot_file_found
    
    ; show error info
.boot_file_not_found:
    mov ah, 0x03    
    mov si, kernel.boot_file_not_found
    mov dl, 4
    mov dh, 1
    mov bx, 0
    mov cx, 2
    int 0x81 
    
    jmp $
    
    ; show success info
.boot_file_found:
    mov ah, 0x03
    mov si, kernel.boot_file_found
    mov dl, 14
    mov dh, 1
    mov bx, 0
    mov cl, 2
    int 0x81
    
    ;print address 
    mov ah, 0x03                                            ; draw string by length
    mov al, 4                                               ; length of string    
    mov si, iso9660_fileDescriptor.locationOfExtendLBA1
    mov dl, 0                                               ; foreground
    mov dh, 0                                               ; background
    mov bx, 20                                              ; x
    mov cl, 2
    int 0x81
    
    ;print address human
    mov ah, 0x05                                            ; draw hex
    mov al, byte [iso9660_fileDescriptor.locationOfExtendLBA1]    
    mov dl, 15                                              ; foreground
    mov dh, 0                                               ; background
    mov bx, 40         ; x
    mov cl, 2
    int 0x81
    
    ; load kernel
    mov dword[iso9660_fileDescriptor.locationOfExtendLBA1], eax
    mov eax, dword [kernel_transfer_model.startingAbsoluteBlock]
    
    mov ah, 0x42										
	mov dl, [kernel.drive_id]							
	mov si, kernel_transfer_model						
	int 0x13

    ;jmp 0x1000:0x0000 
    
    ret