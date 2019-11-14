org 0x0000

mov [kernel.boot_drive_id], dl
mov [kernel.drive_id], dl

jmp boot

kernel:
    .boot_drive_id: db 0x00
    .drive_id: db 0x00

dependencies:
	%include 'cli.asm'

boot:
	call command_line_interface


