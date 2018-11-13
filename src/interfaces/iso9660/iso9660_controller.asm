; controller for rom iso9660

iso9660_getFile:
	call iso9660_getFirstFile
	call iso9660_getNextFile
	ret

iso9660_getFirstFile:
	push es
	mov ax, 0x1000
	mov es, ax
	mov al, byte[es:0]
	mov [iso9660_fileDescriptor.lengthOfDirectoryRecord], al
	
	or al, al															; no file found
	jz .iso9660_getFirstFile_error
	
	mov al, byte[es:1]
	mov [iso9660_fileDescriptor.extendedAttributeRecordLength], al
	mov eax, dword[es:2]
	mov [iso9660_fileDescriptor.locationOfExtendLBA1], eax
	mov eax, dword[es:6]
	mov [iso9660_fileDescriptor.locationOfExtendLBA2], eax
	mov eax, dword[es:10]
	mov [iso9660_fileDescriptor.dataLength1], eax
	mov eax, dword[es:14]
	mov [iso9660_fileDescriptor.dataLength2], eax
	mov al, byte[es:21]
	mov [iso9660_fileDescriptor.fileFlags], al
	mov al, byte[es:32]
	mov [iso9660_fileDescriptor.lengthOfFileIdentifier], al
	xor cx, cx
	mov cl, al
	mov si, 33
	xor bx, bx
	.iso9660_getFirstFile_getFileName:
		mov al, byte[es:si + bx]
		mov [iso9660_fileDescriptor.fileIdentifier + bx], al
		dec cx
		inc bx
		or cx, 0x0000
		jnz .iso9660_getFirstFile_getFileName
		mov byte [iso9660_fileDescriptor.fileIdentifier + bx], 0
	jmp .iso9660_getFirstFile_end
	
	.iso9660_getFirstFile_error:
		stc																	; set carry flag
	
	.iso9660_getFirstFile_end:
		pop es
		ret

iso9660_getNextFile:
	push cx
	push bx
	push es
	push si
	mov ax, 0x1000
	mov es, ax
	mov bx, 0
	mov bl, byte[es:0]
	mov si, 0
	mov cx, 2048
	.iso9660_getNextFile_shiftBuffer:
		mov al, [es:si + bx]
		mov byte[es:si], al
		dec cx
		inc si
		or cx, 0x0000
		jne .iso9660_getNextFile_shiftBuffer
		 
	.iso9660_getNextFile_done:
		pop si
		pop es
		pop bx
		pop cx
	ret

iso9660_getNextDirectory:
	push ax
	push cx
	push bx
	push es
	push si
	mov ax, 0x1000
	mov es, ax
	xor ax, ax

	mov al, byte[es:0]
	test al, 1			; check if even
	jz .iso9660_getNextDirectory_even
	add al, 1
	.iso9660_getNextDirectory_even:
	add al, 8
	mov bx, ax
	mov si, 0
	mov cx, 2048
	.iso9660_getNextDirectory_shiftBuffer:
		mov al, [es:si + bx]
		mov byte[es:si], al
		dec cx
		inc si
		or cx, 0x0000
		jne .iso9660_getNextDirectory_shiftBuffer
		 
	.iso9660_getNextFile_done:
		pop si
		pop es
		pop bx
		pop cx
		pop ax
	ret
	
iso9660_getFirstDirectory:
	call iso9660_getROMInformation									; get rom information
	mov ax, [iso9660_volumeDescriptor.sectorOfPathTableLE1]
	mov word [discAddressPacket.startingAbsoluteBlock], ax
	mov word [discAddressPacket.numberOfBlockTransfer], 31
	call iso9660_loadSectors
	push es
	mov ax, 0x1000
	mov es, ax
	mov al, byte[es:0]
	mov [iso9660_directoryDescriptor.lengthOfDirectoryIdentifier], al
	mov al, byte[es:1]
	mov [iso9660_directoryDescriptor.extendedAttributeRecordLength], al
	mov eax, dword[es:2]
	mov [iso9660_directoryDescriptor.locationOfExtendLBA], eax
	mov ax, word[es:10]
	mov [iso9660_directoryDescriptor.directoryNumberOfParent], ax
	pop es
	mov ax, [iso9660_directoryDescriptor.locationOfExtendLBA]
	mov word [discAddressPacket.startingAbsoluteBlock], ax
	mov word [discAddressPacket.numberOfBlockTransfer], 1
	call iso9660_loadSectors
	ret

iso9660_getROMInformation:
	mov word [discAddressPacket.numberOfBlockTransfer], 1
	mov word [discAddressPacket.startingAbsoluteBlock], 0x10
	mov ah, 0x42										; extended function read
	mov dl, [drive_id]								    ; drive id
	mov si, discAddressPacket							; address of reading parameters
	int 0x13											; read sectors and move to standard buffer location 0x1000:0x0000

	push ax					; save register
	push es					; save register
	push di					; save register
	push ds					; save register

	mov es, [discAddressPacket.transferBufferSegment]				; set es segment register
	mov di, [discAddressPacket.transferBufferOffset]				; set di offset register

	mov bx, 0x0000													; segment of boot code
	mov ds, bx														
	mov si, iso9660_volumeDescriptor								; offset of decriptor

	xor bx, bx														; set bx, 0
	.textOperation_printBuffer_output:
		mov ax, word [es:di + bx]
		mov word [ds:si + bx], ax

		inc bx				
		cmp bx, 883		
		jl .textOperation_printBuffer_output
		
	xor bx, bx

	pop ds					; restore 
	pop di					; restore 
	pop es					; restore 
	pop ax					; restore 
	
	ret
	
iso9660_getDirectories:
	mov word [discAddressPacket.numberOfBlockTransfer], 1
	mov bx, [iso9660_volumeDescriptor.sectorOfPathTableLE1]
	mov word [discAddressPacket.startingAbsoluteBlock], bx
	mov ah, 0x42										; extended function read
	mov dl, [drive_id]								    ; drive id
	mov si, discAddressPacket							; address of reading parameters
	int 0x13											; read sectors and move to standard buffer location 0x1000:0x0000
	ret
	

;mov word [discAddressPacket.numberOfBlockTransfer], 10
iso9660_loadSectors:
	mov ah, 0x42										; extended function read
	mov dl, [drive_id]								    ; drive id
	mov si, discAddressPacket							; address of reading parameters
	int 0x13											; read sectors and move to standard buffer location 0x1000:0x0000
	ret

