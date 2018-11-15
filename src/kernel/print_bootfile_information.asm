kernel_print_boot_file_information:

    mov ah, 0x03    ; echo directory entry
    mov si, iso9660_fileDescriptor.fileIdentifier
    mov dl, 2
    mov dh, 0
    xor bx, bx
    mov bl, 3
    xor cx, cx
    mov cl, 3
    int 0x81

    .kernel_print_boot_file_information_print_adr:
        ;print address human

        mov ah, 0x05
        mov al, byte [iso9660_fileDescriptor.locationOfExtendLBA1]
        mov dl, 2
        mov dh, 0
        mov bx, 1
        xor cx, cx
        mov cl, 3
        int 0x81


    .kernel_print_boot_file_information_print_adr_end:

    ret