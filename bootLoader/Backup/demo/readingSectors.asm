readDrivesInformation:
	
	mov ah, 0x42										; extended function read
	mov dl, [bootDriveID]								; drive id
	mov si, discAddressPacket							; address of reading parameters
	int 0x13
	
	mov ah, 0x08										; function buffer output
	mov bx, 0x1000										; segment
	mov cx, 0x0000										; offset
	mov dl, 14											; foreground color
	mov dh, 1											; background color
	int 0x81
	
	mov si, discAddressPacket.startingAbsoluteBlock		; get offset of this variable
	mov bl, byte [ds:si]								; get value (byte is to small but...)
	mov ah, 0x04	; daw byte as int
	mov al, bl
	push bx
	mov dl, 4		; foreground
	mov dh, 0		; background
	mov bx, 12 		; x
	mov cx, 19 		; y
	int 0x81

	mov ah, 0x0000										; wait for keypress
	int 0x16	
	
	pop bx
	
	cmp al, 0x61										; is key="a" next block
	je .nextBlock
	
	cmp al, 0x7A										; is key="y" previous block
	je .prevBlock
	
	jmp readDrivesInformation							; any other key nothing
	
	
	.nextBlock:
		inc bl											; next block
		jmp .done
	
	.prevBlock:
		dec bl											; previous block
		jmp .done
	
	
	.done:
		mov byte [ds:si], bl							; insert new value
	
	jmp readDrivesInformation							; loop
