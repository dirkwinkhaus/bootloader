kernel_print_boot_file_information:
    mov ah, 0x03    ; echo directory entry
    mov si, iso9660_fileDescriptor.fileIdentifier
    mov dl, 15        ; foreground
    mov dh, 1        ; background
    mov bx, 0         ; x
    xor cx, cx         ; y
    mov cl, 3
    int 0x81

    ; print entry type
    mov al, 'F'                                        ; set f for file
    mov bl, [iso9660_fileDescriptor.fileFlags]
    test bl, 4
    jnz .readFilesFromRootDirectory_typeOutput
    mov al, 'D'                                        ; set d for dir
    .readFilesFromRootDirectory_typeOutput:
    mov ah, 0x02
    mov dl, 15
    mov dh, 1
    mov bx, 20
    xor cx, cx
    mov cl, 3
    int 0x81

    ;print address
    mov ah, 0x03
    mov al, 4
    mov si, iso9660_fileDescriptor.locationOfExtendLBA1
    mov dl, 15
    mov dh, 1
    mov bx, 40
    xor cx, cx
    mov cl, 3
    int 0x81

    ;print address human
    mov ah, 0x05
    mov al, byte [iso9660_fileDescriptor.locationOfExtendLBA1]
    mov dl, 15
    mov dh, 1
    mov bx, 30
    xor cx, cx
    mov cl, 3
    int 0x81

    ret