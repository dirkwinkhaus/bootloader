;string data for output

;kernel info
str_kernel_version db '0.0.2', 0
str_kernel_kernel db 'nanoos kernel ', 0
str_kernel_loaded db ' loaded.', 0
str_kernel_debug db '*DEBUG+', 0
str_kernel_about db 'nanoos', 0x0D, 0x0A, '------', 0x0D, 0x0A, 'lorem ipsum dolor set amet.', 0x0D, 0x0A, 0


;command info
str_command_prompt db '>>', 0
str_command_commandNotFound db 'command not found.', 0x0D, 0x0A, 0
str_command_add_result times 12 db 0

;command data
cmd_noCommand db 0
cmd_about db 'about', 0
cmd_version db 'version', 0
cmd_how db 'how', 0
cmd_add db 'add', 0
cmd_reboot db 'reboot', 0


;buffer data
nano_io_readLine_buffer times 63 db 0

cmd_parameter_1 times 63 db 0
cmd_parameter_2 times 63 db 0
cmd_parameter_3 times 63 db 0

nano_io_intToStr_int dw 0
nano_io_intToStr_base dw 0
nano_io_intToStr_length db 0


mov word[nano_io_intToStr_base], 10
mov byte[nano_io_intToStr_length], 10
