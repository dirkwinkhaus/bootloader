kernel_transfer_model:
    .packetSize:            db 0x10             ; size of packet (10h or 18h)
    .reserved:              db 0x00             ; reserved
    .numberOfBlockTransfer: dw 0x01             ; number of blocks to transfer (max 007Fh for Phoenix EDD)
    .transferBufferOffset:  dw 0x0000           ; transfer buffer offset
    .transferBufferSegment: dw 0x2000           ; transfer buffer segment
    .startingAbsoluteBlock: dq 0x10             ; starting absolute block number (for non-LBA devices, compute as (Cylinder*NumHeads + SelectedHead) * SectorPerTrack + SelectedSector - 1
    .edd3Optional:          dq 0                ; 64-bit flat address of transfer buffer used if DWORD at 04h is FFFFh:FFFFh
