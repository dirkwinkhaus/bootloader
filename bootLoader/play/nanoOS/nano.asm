;nano kernel functions

; show debug info
nano_debug:
	mov si, str_kernel_debug
	call nano_io_printString
	ret


; shows startup info
nano_showStartupInfo:
	mov si, str_kernel_kernel
	call nano_io_printString
	mov si, str_kernel_version
	call nano_io_printString
	mov si, str_kernel_loaded
	call nano_io_printString
	ret
	

; draws prompt
nano_showPromt:
	mov si, str_command_prompt
	call nano_io_printString
	ret
	
	
; shows info command not found
nano_commandNotFound:
	mov si, str_command_commandNotFound
	call nano_io_printString
	call nano_io_newLine
	ret
	

; interpretes a command in si
nano_interpretCommand:
	mov si, nano_io_readLine_buffer
	

	; is the command nothing?
	mov di, cmd_noCommand
	call nano_io_compareStringsTillSpace
	jc nano_command_noCommand

	; is the command nothing?
	mov di, cmd_exit
	call nano_io_compareStringsTillSpace
	jc nano_command_exit

	; is the command about?
	mov di, cmd_about
	call nano_io_compareStringsTillSpace
	jc nano_command_about

	; is the command version?
	mov di, cmd_version
	call nano_io_compareStringsTillSpace
	jc nano_command_version

	; is the command version?
	mov di, cmd_reboot
	call nano_io_compareStringsTillSpace
	jc nano_command_reboot

	; is the command how?
	mov di, cmd_how
	call nano_io_compareStringsTillSpace
	jc nano_command_how

	jmp nano_command_commandNotFound
	
; ----------------------------------------------------------------------
; command section of nano

; no command do nothing
nano_command_noCommand:
	ret

; about command
nano_command_about:
	mov si, str_kernel_about
	call nano_io_printString
	call nano_io_newLine
	ret

; version command
nano_command_version:
	mov si, str_kernel_kernel
	call nano_io_printString
	mov si, str_kernel_version
	call nano_io_printString
	call nano_io_newLine
	call nano_io_newLine
	ret

; reboot command
nano_command_reboot:
	int 0x19
	ret

; reboot command
nano_command_exit:
	pop ax
	mov ax, 0x0000
	mov es, ax
	mov ds, ax
	jmp 0x000:0x7c00
	

; how /help command
nano_command_how:
	; add command
	mov si, cmd_parameter_1						; compare parameter 1
	mov di, cmd_add								; with command "add"
	call nano_io_compareStrings
	jc .nano_command_how_add

	; version command
	mov si, cmd_parameter_1
	mov di, cmd_version
	call nano_io_compareStrings
	jc .nano_command_how_version

	; about command
	mov si, cmd_parameter_1
	mov di, cmd_about
	call nano_io_compareStrings
	jc .nano_command_how_about

	; reboot command
	mov si, cmd_parameter_1
	mov di, cmd_reboot
	call nano_io_compareStrings
	jc .nano_command_how_reboot

	; nothing found
	jmp .nano_command_how_done_notFound
	
	.nano_command_how_add:
		mov si, str_info_how_add
		call nano_io_printString
		jmp .nano_command_how_done
		
	.nano_command_how_version:
		mov si, str_info_how_version
		call nano_io_printString
		jmp .nano_command_how_done
		
	.nano_command_how_about:
		mov si, str_info_how_about
		call nano_io_printString
		jmp .nano_command_how_done
		
	.nano_command_how_reboot:
		mov si, str_info_how_reboot
		call nano_io_printString
		jmp .nano_command_how_done
		
	.nano_command_how_done_notFound:
		mov si, str_info_how_noResult
		call nano_io_printString
	
	.nano_command_how_done:
		call nano_io_newLine
		call nano_io_newLine
	ret

nano_command_commandNotFound:
	call nano_commandNotFound
	ret

%include 'nanoOS\how.asm'
