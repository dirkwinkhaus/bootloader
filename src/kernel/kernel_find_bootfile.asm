kernel_find_bootfile:   
    ;print copyright info
    mov ah, 0x03    ; draw string
    mov si, kernel.str_boot_lookup_info
    mov dl, 2        ; foreground
    mov dh, 0        ; background
    mov bx, 0         ; x
    mov cx, 0         ; y
    int 0x81 

    mov ebx, [iso9660_volumeDescriptor]
    mov es, [iso9660_volumeDescriptor]
    call iso9660_getFirstDirectory
    call iso9660_getNextFile

    .kernel_find_bootfile_loop:
        call iso9660_getNextFile
        call iso9660_getFirstFile
        jc .kernel_find_bootfile_loop_end

        ; compare kernel file name with found file
        mov ah, 0x0D
        mov si, kernel.boot_file_name
        mov di, iso9660_fileDescriptor.fileIdentifier
        XOR cx, cx
        int 0x81

        cmp al, 1
        je .kernel_find_bootfile_loop_end
        
        jmp .kernel_find_bootfile_loop
    .kernel_find_bootfile_loop_end:

    ret
