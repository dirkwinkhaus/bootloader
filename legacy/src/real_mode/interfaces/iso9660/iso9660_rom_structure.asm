; loading rom parameter
discNavigationPacket:
    .drive:                 db 0
    .directoryId:           dw 0
    .parentDirectoryId:     dw 0
    .directoryName:         times 33 db 0
    .fileName:              times 33 db 0

discAddressPacket:
    .packetSize:            db 0x10             ; size of packet (10h or 18h)
    .reserved:              db 0x00             ; reserved
    .numberOfBlockTransfer: dw 0x01             ; number of blocks to transfer (max 007Fh for Phoenix EDD)
    .transferBufferOffset:  dw 0x0000           ; transfer buffer offset
    .transferBufferSegment: dw 0x1000           ; transfer buffer segment
    .startingAbsoluteBlock: dq 0x10             ; starting absolute block number (for non-LBA devices, compute as (Cylinder*NumHeads + SelectedHead) * SectorPerTrack + SelectedSector - 1
    .edd3Optional:          dq 0                ; 64-bit flat address of transfer buffer used if DWORD at 04h is FFFFh:FFFFh

; disc information parameter
discInformationBuffer:
    .packetSize:            db 0x13
    .bootMediaType:         db 0                ; BITS[0-3] (0 = no emulation; 1 = 1.2mb disk; 2= 1.44mb disk; 3 = 2.88 mb disk; 4 = hard disk)
                                                ; BITS[4-5] RESERVED HAS TO BE 0
                                                ; BITS[6] (1 = image contains ATAPI driver)
                                                ; BITS[7] (1 = image contains SCSI driver)
                                                ; BITS[8-9] (ATAPI: refer to IDE interface; SCSI: refer to SCSI interface)
    .driveNumber:           db 0                ; (0 = floppy; ...; 80 = hard disk; ...)
    .controllerIndex:       db 0                ; controller nb of the cd drive
    .logicalBlockAddress:   dd 0                ; LBA for the dik image to be emulated
    .deviceSpecification:   dw 0                ; For SCSI controllers byte 8 is the LUN and PUN of the CD Drive, byte 9 is the Bus number.  For IDE controllers the low order bit of byte 8 specifies master/slave device, 0 = master.
    .userBufferSegment:     dw 0                ; User Buffer Segment.  If this field is non-zero it specifies the segment of a user supplied 3k buffer for caching CD reads.  This buffer will begin at Segment:0.
    .loadSegment:           dw 0                ; Load Segment.  This is the load address for the initial boot image.  If this value is 0 the system will use the traditional segment of 7C0.  If this value is non-zero the system will use the specified address.  This field is only valid for function 4C
    .sectorCount:           dw 0                ; Sector Count.  This is the number of virtual sectors the system will store at Load Segment during the initial boot procedure.  This field is only valid for function 4C
    .cylinderCount:         db 0                ; Bits 0-7 of the cylinder count.  This should match the value returned in CH when INT 13 function 08 is invoked.
    .returnedCl:            db 0                 ; This is the value returned in the CL register when INT 13 function 08 is invoked.  Bits 0-5 are the sector count.  Bits 6 and 7 are the high order 2 bits of the cylinder count.
    .headCount:             db 0                ; This is the head count, it should match the value in DH when INT 13 Function 08 is invoked.

