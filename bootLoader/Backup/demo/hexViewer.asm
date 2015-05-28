	mov ah, 0x0B	; clears whole screen
	mov dl, 14		; foreground
	mov dh, 1		; background
	int 0x81
	
	mov ah, 0x03	; draw string
	mov si, str_copyrightInfo
	mov dl, 14		; foreground
	mov dh, 1		; background
	mov bx, 0 		; x
	mov cx, 0 		; y
	int 0x81

	mov si, str_programIntro
	mov bx, 0 		; x
	mov cx, 1 		; y
	int 0x81

	mov si, str_keyInfo
	mov bx, 0 		; x
	mov cx, 24 		; y
	int 0x81
	
	mov si, str_offsetInfo
	mov bx, 30 		; x
	mov cx, 24 		; y
	int 0x81
	
	
	mov word [discAddressPacket.numberOfBlockTransfer], 30
	call iso9660_loadSectors
	
		mov bx, 0
		push bx

		.readDataFromMemory:
			mov ah, 0x0A	; draw part of buffer
			mov bx, 0x1000
			mov ds, bx 		; set data segment
			pop bx
			mov si, bx 		; set data offset
			push bx
			mov bh, 5 		; x
			mov bl, 4 		; y
			mov cx, 1520	; how many charachters of buffer shown
			mov dh, 0x0000
			mov dl, 0x2
			int 0x81
			
			
			; show offset
			pop bx								; get offset
			mov ah, 0x05	; draw byte as hex
			mov al, bl
			push bx
			mov dl, 14		; foreground
			mov dh, 1		; background
			mov bx, 41 		; x
			mov cx, 24 		; y
			int 0x81
			
			pop bx								; get offset
			mov ah, 0x05	; draw byte as hex
			mov al, bh
			push bx
			mov dl, 14		; foreground
			mov dh, 1		; background
			mov bx, 39 		; x
			mov cx, 24 		; y
			int 0x81
			;=================================
			
			; show selected bytes
			
			mov ah, 0x0C	; draw string by length
			mov al, 10		; how often place attributes
			mov dl, 1		; foreground
			mov dh, 14		; background
			mov bx, 0 		; x
			mov cx, 4 		; y
			int 0x81

			;=================================
			
			; print hex of selected bytes
			pop bx
			push si
			push ds
			mov ax, 0x1000
			mov ds, ax
			mov si, bx
			push bx
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 0]
			mov dl, 14		; foreground
			mov dh, 1		; background
			mov bx, 31 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 1]
			mov bx, 33 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 2]
			mov bx, 35 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 3]
			mov bx, 37 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 4]
			mov bx, 39 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 5]
			mov bx, 41 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 6]
			mov bx, 43 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 7]
			mov bx, 45 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 8]
			mov bx, 47 		; x
			mov cx, 3 		; y
			int 0x81
			
			mov ah, 0x05	; draw byte as hex
			mov al, [ds:si + 9]
			mov bx, 49 		; x
			mov cx, 3 		; y
			int 0x81
			
			pop bx
			pop ds
			pop si
			push bx
			
			;=================================
			mov ah, 0x0							; get key
			int 0x16
			
			pop bx
			
			cmp al, '0'
			je .goto0

			cmp al, 's'
			je .goUp80

			cmp al, 'w'
			je .goDown80
			
			cmp al, 'd'
			je .goUp1

			cmp al, 'a'
			je .goDown1
			
			cmp al, 'f'
			je .goUpSector
			
			cmp al, 'r'
			je .goDownSector
			
			jmp .endOfReadingMemory
			
			.goto0:
				mov bx, 0
				jmp .endOfReadingMemory
			
			.goUp80:
				mov ax, 80
				add bx, ax
				jmp .endOfReadingMemory
			
			.goDown80:
				mov ax, 80
				sub bx, ax
				jmp .endOfReadingMemory
			
			.goUp1:
				mov ax, 1
				add bx, ax
				jmp .endOfReadingMemory
			
			.goDown1:
				mov ax, 1
				sub bx, ax
				jmp .endOfReadingMemory
			
			.goUpSector:
				mov ax, 2048
				add bx, ax
				jmp .endOfReadingMemory
			
			.goDownSector:
				mov ax, 2048
				sub bx, ax
				jmp .endOfReadingMemory
			
			.endOfReadingMemory:
			push bx

		
		jmp .readDataFromMemory
