file_information_ex:
    .packet_size:             db 0x10             ; size of packet (10h or 18h)
    .reserved:                db 0x00             ; reserved
    .blocks_to_transfer:      dw 0x01             ; number of blocks to transfer (max 007Fh for Phoenix EDD)
    .transfer_buffer_offset:  dw 0x0000           ; transfer buffer offset
    .transfer_buffer_segment: dw 0x1000           ; transfer buffer segment
    .starting_absolute_block: dq 0x10             ; starting absolute block number (for non-LBA devices, compute as (Cylinder*NumHeads + SelectedHead) * SectorPerTrack + SelectedSector - 1
    .edd3_optional:           dq 0                ; 64-bit flat address of transfer buffer used if DWORD at 04h is FFFFh:FFFFh
