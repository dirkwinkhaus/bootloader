jmp sos_Commander
sosCommander:
	.str_copyrightInfo:			db 'sosCommander (c)opyright by dirk winkhaus, 2014 - version 1.0.1', 0
								   ;0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	.str_programIntro:			db ' item               type     sector    ', 0
	.str_keyInfo:				db 'browse files with w/s/e/r/x', 0
	.screenYPosition:			db 3
	.str_keyPressInfo:			db 'Key:', 0
	.marker:					db '>'
	.marker_x:					db 0
	.marker_y:					db 2
	.markerMinY					db 2
	.markerMaxY					db 2
	.key						db 0
	.directoryIndex				db 0

sos_Commander:

	mov ah, 01
	mov cx, 0x2607
	int 0x10
	
	
	.handleCommander:
		call sos_commander_prepareScreen
		; print key
		mov ah, 0x05						; draw key in hex
		mov al, [sosCommander.key]
		mov dl, 2							; foreground
		mov dh, 1							; background
		mov bx, 79 							; x
		mov cx, 24 							; y
		int 0x81
		call sos_commander_listDirectory


		mov ah, 0x0							; get key
		int 0x16
		
		mov [sosCommander.key], al
		
		cmp al, 's'
		je .stepMarkerDown
		
		cmp al, 'w'
		je .stepMarkerUp
		
		cmp al, 'r'
		je .loadFile
		
		cmp al, 'e'
		je .execFile
		
		jmp .handleCommander

		.loadFile:
			mov ah, 02
			int 0x90
			mov ah, 0x1	; draw charachter
			mov bx, 40 	; x
			mov cx, 0 	; y
			mov cl, [sosCommander.marker_y] 	; y
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

			jmp .handleCommander
		
		.execFile:
			mov ah, 0x1	; draw charachter
			mov bx, 40 	; x
			mov cx, 0 	; y
			mov cl, [sosCommander.marker_y] 	; y
			int 0x81

			mov word [discAddressPacket.numberOfBlockTransfer], 1
			mov [discAddressPacket.startingAbsoluteBlock], al
			call iso9660_loadSectors
		
			push ds
			push si
			mov ax, 0x1000
			mov ds, ax 			; set data segment
			mov ah, 0x01
			mov si, 0 			; set data offeset
			mov cx, 2048			; how many bytes
			int 0x90
			pop si
			pop ds
			mov ax, 0x2000
			mov es, ax
			mov ds, ax
			push .handleCommander
			jmp 0x2000:0x0000
		
		.stepMarkerDown:
			mov al, byte[sosCommander.markerMaxY] 
			cmp byte[sosCommander.marker_y],  al; marker is most bottom
			jge .handleCommander
			inc byte [sosCommander.marker_y]	; set marker one down
			jmp .handleCommander
		
		.stepMarkerUp:
			mov al, byte[sosCommander.markerMinY] 
			cmp byte[sosCommander.marker_y],  al; marker is most top
			jle .handleCommander
			dec byte [sosCommander.marker_y]	; set marker one down
			jmp .handleCommander
		
		jmp .handleCommander

	.endOfProc:
		mov ah, 0x0B	; clears whole screen
		mov dl, 2		; foreground
		mov dh, 0		; background
		int 0x81
	ret

;--------------SUBROUTINES------------------------------------
	
sos_commander_prepareScreen:
	pusha
	; clear screen
	mov ah, 0x0B	; clears whole screen
	mov dl, 15		; foreground
	mov dh, 0		; background
	int 0x81
	
	;print copyright info
	mov ah, 0x03	; draw string
	mov si, sosCommander.str_copyrightInfo
	mov dl, 14		; foreground
	mov dh, 1		; background
	mov bx, 0 		; x
	mov cx, 0 		; y
	int 0x81

	;print prog info
	mov si, sosCommander.str_programIntro
	mov bx, 0 		; x
	mov cx, 1 		; y
	int 0x81
	
	mov si, sosCommander.str_keyPressInfo
	mov bx, 74 		; x
	mov cx, 24 		; y
	int 0x81
	
	mov si, sosCommander.str_keyInfo
	mov bx, 0 		; x
	mov cx, 24 		; y
	int 0x81
	
	;top blue row
	mov ah, 0x0C	; draw string by length
	mov al, 160		; how often place attributes
	mov dl, 14		; foreground
	mov dh, 1		; background
	mov bx, 0 		; x
	mov cx, 0 		; y
	int 0x81

	;bottom blue row
	mov ah, 0x0C	; draw string by length
	mov al, 80		; how often place attributes
	mov dl, 14		; foreground
	mov dh, 1		; background
	mov bx, 0 		; x
	mov cx, 24 		; y
	int 0x81

	; draw prompt
	mov ah, 0x02	; draw charachter
	mov al, [sosCommander.marker]		; char
	mov dl, 14		; foreground
	mov dh, 0		; background
	mov bx, 0 		; x
	mov cx, 0 		; y
	mov bl, byte [sosCommander.marker_x] 		; x
	mov cl, byte [sosCommander.marker_y] 		; y
	int 0x81
	popa
	ret

sos_commander_listDirectory:	
	mov byte [sosCommander.markerMaxY], 2							; reset marker limit
	; get files of root directory	
	mov cx, [sosCommander.directoryIndex]
	
	.sos_commander_listDirectory_indexLoop:
		or cx, cx
		jz .sos_commander_listDirectory_indexLoopEnd
		call iso9660_getNextDirectory								; load root directory
		dec cx
	.sos_commander_listDirectory_indexLoopEnd:
	
	call iso9660_getFirstDirectory								; load root directory
	call iso9660_getNextFile									; delete directory "."
	.readFilesFromRootDirectory:
		call iso9660_getNextFile								
		call iso9660_getFirstFile
		jc .readFilesFromRootDirectory_end						; no file found

		mov ah, 0x03	; draw directory entry
		mov si, iso9660_fileDescriptor.fileIdentifier
		mov dl, 15		; foreground
		mov dh, 0		; background
		mov bx, 1 		; x
		xor cx, cx
		mov cl, byte [sosCommander.screenYPosition]
		int 0x81
		
		mov al, 'F'										; set f for file
		mov bl, [iso9660_fileDescriptor.fileFlags]		; char
		test bl, 4 										; if set it is a directory
		jnz .readFilesFromRootDirectory_typeOutput
	
		; print entry type
		mov al, 'D'										; set d for dir
		.readFilesFromRootDirectory_typeOutput:
		; draw prompt
		mov ah, 0x02	; draw charachter
		mov dl, 14		; foreground
		mov dh, 0		; background
		mov bx, 20 		; x
		mov cx, 0 		; y
		mov cl, byte [sosCommander.screenYPosition] 		; y
		int 0x81
		
		;print address 
		mov ah, 0x03	; draw string by length
		mov al, 4		; length of string	
		mov si, iso9660_fileDescriptor.locationOfExtendLBA1
		mov dl, 0		; foreground
		mov dh, 0		; background
		mov bx, 40 		; x
		mov cx, 0 		; y
		mov cl, byte [sosCommander.screenYPosition]
		int 0x81
		
		;print address human
		mov ah, 0x05	; draw hex
		mov al, byte [iso9660_fileDescriptor.locationOfExtendLBA1]	
		mov dl, 15		; foreground
		mov dh, 0		; background
		mov bx, 30 		; x
		mov cx, 0 		; y
		mov cl, byte [sosCommander.screenYPosition]
		int 0x81
		
		
		
		inc byte [sosCommander.screenYPosition]
		inc byte [sosCommander.markerMaxY]
		
		jmp .readFilesFromRootDirectory
	.readFilesFromRootDirectory_end:
	mov byte [sosCommander.screenYPosition], 3
	ret
