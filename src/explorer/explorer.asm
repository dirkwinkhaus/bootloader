jmp preos_explorer

%include 'interfaces\iso9660\iso9660_rom_structure.asm'
%include 'interfaces\iso9660\iso9660_data_structure.asm'
%include 'interfaces\iso9660\iso9660_controller.asm'
%include 'hex_viewer.asm'

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

drive_id db 0

mov al, drive_id

preos_explorer:

    mov ah, 01
    mov cx, 0x2607
    int 0x10
    
    
    .handle_explorer:
        call sos_commander_prepareScreen
        ; print key
        mov ah, 0x05                        ; draw key in hex
        mov al, [preos_explorer_data.key]
        mov dl, 2                            ; foreground
        mov dh, 1                            ; background
        mov bx, 79                           ; x
        mov cx, 24                           ; y
        int 0x81
        call sos_commander_listDirectory


        mov ah, 0x0                            ; get key
        int 0x16
        
        mov [preos_explorer_data.key], al
        
        cmp al, 's'
        je .step_marker_down
        
        cmp al, 'w'
        je .step_marker_up
        
        cmp al, 'r'
        je .loadFile
        
        cmp al, 'e'
        je .execFile
        
        jmp .handle_explorer

        .loadFile:
            mov ah, 02
            int 0x90
            mov ah, 0x1    ; draw charachter
            mov bx, 40     ; x
            mov cx, 0     ; y
            mov cl, [preos_explorer_data.marker_y]     ; y
            int 0x81
            
            mov word [discAddressPacket.numberOfBlockTransfer], 1
            mov [discAddressPacket.startingAbsoluteBlock], al
            call iso9660_loadSectors
            push es
            push ds
            push si
            call sos_hexViewer1000_0000
            pop si
            pop ds
            pop es

            jmp .handle_explorer
        
        .execFile:
            mov ah, 0x1    ; draw charachter
            mov bx, 40     ; x
            mov cx, 0     ; y
            mov cl, [preos_explorer_data.marker_y]     ; y
            int 0x81

            mov word [discAddressPacket.numberOfBlockTransfer], 1
            mov [discAddressPacket.startingAbsoluteBlock], al
            call iso9660_loadSectors
        
            push ds
            push si
            mov ax, 0x1000
            mov ds, ax             ; set data segment
            mov ah, 0x01
            mov si, 0             ; set data offeset
            mov cx, 2048            ; how many bytes
            int 0x90
            pop si
            pop ds
            mov ax, 0x2000
            mov es, ax
            mov ds, ax
            push .handle_explorer
            jmp 0x2000:0x0000
        
        .step_marker_down:
            mov al, byte[preos_explorer_data.markerMaxY] 
            cmp byte[preos_explorer_data.marker_y],  al    ; marker is most bottom
            jge .handle_explorer
            inc byte [preos_explorer_data.marker_y]        ; set marker one down
            jmp .handle_explorer
        
        .step_marker_up:
            mov al, byte[preos_explorer_data.markerMinY] 
            cmp byte[preos_explorer_data.marker_y],  al    ; marker is most top
            jle .handle_explorer
            dec byte [preos_explorer_data.marker_y]        ; set marker one down
            jmp .handle_explorer
        
        jmp .handle_explorer

    .preos_explorer_end:
        mov ah, 0x0B                                ; clears whole screen
        mov dl, 2                                   ; foreground
        mov dh, 0                                   ; background
        int 0x81
    ret

;--------------SUBROUTINES------------------------------------
    
sos_commander_prepareScreen:
    pusha
    ; clear screen
    mov ah, 0x0B    ; clears whole screen
    mov dl, 15        ; foreground
    mov dh, 0        ; background
    int 0x81
    
    ;print copyright info
    mov ah, 0x03    ; draw string
    mov si, preos_explorer_data.str_copyrightInfo
    mov dl, 14        ; foreground
    mov dh, 1        ; background
    mov bx, 0         ; x
    mov cx, 0         ; y
    int 0x81

    ;print prog info
    mov si, preos_explorer_data.str_programIntro
    mov bx, 0         ; x
    mov cx, 1         ; y
    int 0x81
    
    mov si, preos_explorer_data.str_keyPressInfo
    mov bx, 74         ; x
    mov cx, 24         ; y
    int 0x81
    
    mov si, preos_explorer_data.str_keyInfo
    mov bx, 0         ; x
    mov cx, 24         ; y
    int 0x81
    
    ;top blue row
    mov ah, 0x0C    ; draw string by length
    mov al, 160        ; how often place attributes
    mov dl, 14        ; foreground
    mov dh, 1        ; background
    mov bx, 0         ; x
    mov cx, 0         ; y
    int 0x81

    ;bottom blue row
    mov ah, 0x0C    ; draw string by length
    mov al, 80        ; how often place attributes
    mov dl, 14        ; foreground
    mov dh, 1        ; background
    mov bx, 0         ; x
    mov cx, 24         ; y
    int 0x81

    ; draw prompt
    mov ah, 0x02    ; draw charachter
    mov al, [preos_explorer_data.marker]        ; char
    mov dl, 14        ; foreground
    mov dh, 0        ; background
    mov bx, 0         ; x
    mov cx, 0         ; y
    mov bl, byte [preos_explorer_data.marker_x]         ; x
    mov cl, byte [preos_explorer_data.marker_y]         ; y
    int 0x81
    popa
    ret

sos_commander_listDirectory:    
    mov byte [preos_explorer_data.markerMaxY], 2                            ; reset marker limit
    ; get files of root directory    
    mov cx, [preos_explorer_data.directoryIndex]
    
    .sos_commander_listDirectory_indexLoop:
        or cx, cx
        jz .sos_commander_listDirectory_indexLoopEnd
        call iso9660_getNextDirectory                                ; load root directory
        dec cx
    .sos_commander_listDirectory_indexLoopEnd:
    
    call iso9660_getFirstDirectory                                ; load root directory
    call iso9660_getNextFile                                    ; delete directory "."
    .readFilesFromRootDirectory:
        call iso9660_getNextFile                                
        call iso9660_getFirstFile
        jc .readFilesFromRootDirectory_end                        ; no file found

        mov ah, 0x03    ; draw directory entry
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
