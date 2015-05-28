; sosLib 1.0.0
; 

; must be first
sosLib_dataInit:
	mov [bootDriveID], dl													; save boot drive id
	%include 'sosLib\interrupts\sosInt81.asm'								; loads interrupt 81h
	%include 'sosLib\interrupts\sosInt90.asm'								; loads interrupt 81h

jmp sosLib_end
sosLib_dataBegin:
	%include 'sosLib\data\romDataStructure.asm'								; loads interrupt 81h
	%include 'sosLib\data\variables.asm'									; 
	%include 'sosLib\data\strings.asm'										; 
	%include 'sosLib\iso9660\iso9660_controller.asm'						; 
	%include 'sosLib\iso9660\iso9660_dataStructure.asm'						; 
	%include 'sosLib\sosTools\sosHexViewer\sosHexViewer.asm'				; 
	%include 'sosLib\sosTools\sosTerminal\sosTerminal.asm'					; 
	%include 'sosLib\sosTools\sosCommander\sosCommander.asm'				; 

sosLib_end: