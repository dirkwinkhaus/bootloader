org 0x7C00                                      ; setup start address
jmp load_sys_dependencies                           ; load library in 2nd sector

%include 'bootloader/bootloader_model.asm'

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
    %include 'bootloader/interrupts/int_81.asm'          ; loads interrupt 81h
    %include 'bootloader/interrupts/int_90.asm'          ; loads interrupt 81h
    jmp start

load_dependencies:
    %include 'bootloader/interfaces/iso9660/iso9660_rom_structure.asm'
    %include 'bootloader/interfaces/iso9660/iso9660_data_structure.asm'
    %include 'bootloader/interfaces/iso9660/iso9660_controller.asm'
    %include 'bootloader/bootloader_transfer_model.asm'
    %include 'bootloader/print_bootfile_information.asm'
    %include 'bootloader/bootloader_find_bootfile.asm'

    ;temp remove later
    ; %include '../explorer/hex_viewer.asm'

; show error info
boot_file_not_found:
    mov ah, 0x03
    mov si, kernel.boot_file_not_found
    mov dl, 4
    mov dh, 0
    mov bx, 0
    mov cx, 1
    int 0x81

    jmp $

; show success info
boot_file_found:
    mov ah, 0x03
    mov si, kernel.boot_file_found
    mov dl, 2
    mov dh, 0
    mov bx, 0
    mov cl, 1
    int 0x81

    call kernel_print_boot_file_information

    mov ah, 0x03
    mov si, kernel.loading_terminal
    mov dl, 2
    mov dh, 0
    mov bx, 0
    mov cl, 2
    int 0x81

;wait here for information displayed
    mov ah, 0x86
    mov cx, 6
    int 0x15

    mov eax, dword [iso9660_fileDescriptor.locationOfExtendLBA1]
	mov word [discAddressPacket.numberOfBlockTransfer], 1
	mov [discAddressPacket.startingAbsoluteBlock], eax
	call iso9660_loadSectors

	pop si
	pop ds
	mov ax, 0x1000
	mov es, ax
	mov ds, ax
	jmp 0x1000:0x0000

    ret