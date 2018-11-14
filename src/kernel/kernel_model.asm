kernel:
    .version: db 1, '0.0.7', 2
    .boot_drive_id: db 0				; boot drive id
    .drive_id: db 0
    .str_boot_lookup_info: db 'Looking for boot.do...', 0
    .boot_file_name: db 'BOOTFILE.DO', 0
    .boot_file_found: db 'Found kernel file.', 0
    .boot_file_not_found: db 'Kernel file not found.', 0
