org 0x7C00								; setup start address 
jmp sosLibInit							; put loading in 2nd sector
db 0, 0, 'version: 0.0.1', 0, 0
xPos db 2
maxLength dw 4

beginBootLoader:
	mov ah, 0x0B	; empties screen buffer from position bx, cx in direction dl (0=left /1=right) by length al
	mov dl, 0		; to the left
	mov dh, 1		; background color
	int 0x81

	call iso9660_getROMInformation

	mov bx, 0x0000
	mov si, iso9660_volumeDescriptor.dateOfCreation
	mov word [maxLength], 8

	
	.loop:
		mov al, byte [ds:si + bx]
		inc bx
		push bx

		mov ah, 0x05	; draw byte as hex
		mov dl, 14		; foreground
		mov dh, 1		; background
		mov bh, 0x000
		mov bl, byte [xPos]	; x
		mov cx, 0 		; y
		int 0x81
		pop bx
		
		inc byte[xPos]
		inc byte[xPos]
		inc byte[xPos]
		
		cmp bx, [maxLength]
		jne .loop
	
	
	mov byte [xPos], 2
	xor bx, bx
	.loop2:
		mov al, byte [ds:si + bx]
		inc bx
		push bx

		mov ah, 0x02	; draw byte as hex
		mov dl, 14		; foreground
		mov dh, 1		; background
		mov bh, 0x000
		mov bl, byte [xPos]	; x
		mov cx, 5 		; y
		int 0x81
		pop bx
		
		inc byte[xPos]
		inc byte[xPos]
		inc byte[xPos]
		
		cmp bx, [maxLength]
		jne .loop2
	


	mov ah, 00
	int 0x16

	
	call iso9660_getROMInformation

	mov ah, 0x09	; draw string
	mov al, 32		; if al not 0 print string until 4 chars reached
	mov si, iso9660_volumeDescriptor.systemIdentifier
	mov dl, 14		; foreground
	mov dh, 1		; background
	mov bx, 0 		; x
	mov cx, 0 		; y
	int 0x81

	mov ah, 0x09	; draw string
	mov al, 32		; if al not 0 print string until 4 chars reached
	mov si, iso9660_volumeDescriptor.volumeIdentifier
	mov cx, 1 		; y
	int 0x81
	
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

testHex db 0xf0, 0xf1, 0xf2, 0xf3, 0xf4
times 2046-($-$$) db 0 						; fill rest with 0 to fill sector
dw 0xAA55									;end of boot sector

sosLibInit:
	%include 'sosLib\sosLib.asm'							; load sosLib.asm
	jmp beginBootLoader
	
times 18 db 'sosMeansSilentOS|'