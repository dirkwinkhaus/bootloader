;######################## EXTENDED EXECUTION CONTROLLER #######################
;#  (c)opyright by dirk winkhaus
;#
;#  FUNCTION CALL:           DESCRIPTION:
;#
;#  mov ah, 0x01
;#  mov si, .............
;#
;##############################################################################

; init interrupts
push es
push bx
push ax

;INIT INT90h---------------------------------------------------
mov bx, 0
mov es, bx

mov dx, extended_execution_controller
mov [es:0x92*4], dx
mov ax, cs
mov [es:0x92*4+2], ax
;--------------------------------------------------------------
pop ax
pop bx
pop es

jmp extended_execution_controller.end
; ==============================================================

extended_execution_controller:
;	cmp ah, 0x01
;	je .load_file_from_rom_and_execute

	;-------------------------------------------------------------
	jmp .end
	.dependencies:
;		%include '../interfaces/iso9660/iso9660_rom_structure.asm'
    	%include '../interfaces/iso9660/iso9660_data_structure.asm'
;    	%include '../interfaces/iso9660/iso9660_controller.asm'
    	%include '../interfaces/int_92.asm'

    .drive_id: db 0

	;-------------------------------------------------------------
	; mov ah, 0x01	 	; function
	; mov al, 0x10		; drive id
	; mov si, file_name ; label to filename
	.load_file_from_rom_and_execute:
		mov .drive_id, al
		push ax

        ;call iso9660_getFirstDirectory
        ;call iso9660_getNextFile

        .load_file_from_rom_and_execute_loop:
            ;call iso9660_getNextFile
            ;call iso9660_getFirstFile
            ;jc .load_file_from_rom_and_execute_file_not_found

            mov ah, 0x0D
            mov di, iso9660_fileDescriptor.fileIdentifier
            mov cx, 0
            int 0x81

            cmp al, 1
            je .load_file_from_rom_and_execute_find_file

            jmp .load_file_from_rom_and_execute_loop
        .load_file_from_rom_and_execute_file_not_found:
        	stc
        	jmp .load_file_from_rom_and_execute_end

        .load_file_from_rom_and_execute_find_file:

		;mov eax, dword [iso9660_fileDescriptor.locationOfExtendLBA1]
		;mov word [file_information_ex.blocks_to_transfer], 1
		;mov [file_information_ex.starting_absolute_block], eax

		;mov ah, 0x42										; extended function read
		;mov dl, [.drive_id]								    ; drive id
		;mov si, file_information_ex							; address of reading parameters
		;int 0x13											; read sectors and move to standard buffer location 0x1000:0x0000

		pop si
		pop ds
		mov ax, 0x1000
		mov es, ax
		mov ds, ax
		jmp 0x1000:0x0000

		.load_file_from_rom_and_execute_end:
		pop ax
		iret
	;-------------------------------------------------------------

	.end: