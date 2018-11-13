org 0x7C00                                      ; setup start address 
jmp load_dependencies                           ; load library in 2nd sector
version                     db 1, '0.0.7', 2
boot_drive_id 				db 0				; boot drive id
drive_id db 0



start:
    mov ah, 0x0B                                ; clears whole screen
    mov dl, 14                                  ; foreground
    mov dh, 1                                   ; background
    int 0x81

    call sos_commander_listDirectory;
    ; jmp start
    jmp $                                       ; stay here

    times 2046-($-$$) db 0                      ; fill rest with 0 to fill sector
    dw 0xAA55                                   ; end of boot sector
    
load_dependencies:
    mov [boot_drive_id], dl     ; save boot drive id
    mov [drive_id], dl     ; set drive id
    %include 'interrupts\sosInt81.asm'          ; loads interrupt 81h
    %include 'interrupts\sosInt90.asm'          ; loads interrupt 81h
    %include '../interfaces\iso9660\iso9660_rom_structure.asm'
    %include '../interfaces\iso9660\iso9660_data_structure.asm'
    %include '../interfaces\iso9660\iso9660_controller.asm'


    jmp start

preos_explorer_data:
    .str_copyrightInfo:         db 'preos explorer (c)opyright by dirk winkhaus | version 1.0.0', 0
                                   ;0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    .str_programIntro:          db ' item               type     sector    ', 0
    .str_keyInfo:               db 'browse files with w/s/e/r/x', 0
    .screenYPosition:           db 3
    .str_keyPressInfo:          db 'Key:', 0
    .marker:                    db '>'
    .marker_x:                  db 0
    .marker_y:                  db 2
    .markerMinY                 db 2
    .markerMaxY                 db 2
    .key                        db 0
    .directoryIndex             db 0

sos_commander_listDirectory:    
    
    call iso9660_getFirstDirectory                                ; load root directory
    call iso9660_getNextFile                                    ; delete directory "."
    .readFilesFromRootDirectory:
        call iso9660_getNextFile                                
        call iso9660_getFirstFile
        jc .readFilesFromRootDirectory_end                        ; no file found

        mov ah, 0x03    ; echo directory entry
        mov si, iso9660_fileDescriptor.fileIdentifier
        mov dl, 15        ; foreground
        mov dh, 0        ; background
        mov bx, 1         ; x
        xor cx, cx
        mov cl, byte [preos_explorer_data.screenYPosition]
        int 0x81
        
        mov al, 'F'                                        ; set f for file
        mov bl, [iso9660_fileDescriptor.fileFlags]        ; char
        test bl, 4                                         ; if set it is a directory
        jnz .readFilesFromRootDirectory_typeOutput
    
        ; print entry type
        mov al, 'D'                                        ; set d for dir
        .readFilesFromRootDirectory_typeOutput:
        ; draw prompt
        mov ah, 0x02    ; draw charachter
        mov dl, 14        ; foreground
        mov dh, 0        ; background
        mov bx, 20         ; x
        mov cx, 0         ; y
        mov cl, byte [preos_explorer_data.screenYPosition]         ; y
        int 0x81
        
        ;print address 
        mov ah, 0x03    ; draw string by length
        mov al, 4        ; length of string    
        mov si, iso9660_fileDescriptor.locationOfExtendLBA1
        mov dl, 0        ; foreground
        mov dh, 0        ; background
        mov bx, 40         ; x
        mov cx, 0         ; y
        mov cl, byte [preos_explorer_data.screenYPosition]
        int 0x81
        
        ;print address human
        mov ah, 0x05    ; draw hex
        mov al, byte [iso9660_fileDescriptor.locationOfExtendLBA1]    
        mov dl, 15        ; foreground
        mov dh, 0        ; background
        mov bx, 30         ; x
        mov cx, 0         ; y
        mov cl, byte [preos_explorer_data.screenYPosition]
        int 0x81
        
        inc byte [preos_explorer_data.screenYPosition]
        inc byte [preos_explorer_data.markerMaxY]
        
        jmp .readFilesFromRootDirectory
    .readFilesFromRootDirectory_end:
    mov byte [preos_explorer_data.screenYPosition], 3
    ret