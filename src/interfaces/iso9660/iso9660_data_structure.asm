iso9660_fileDescriptor:
	.lengthOfDirectoryRecord:			db 0
	.extendedAttributeRecordLength:		db 0
	.locationOfExtendLBA1:				dd 0		        ; in both endian
	.locationOfExtendLBA2:				dd 0		        ; in both endian
	.dataLength1:						dd 0		        ; in both endian
	.dataLength2:						dd 0		        ; in both endian
	.recordingDate:						times 7 db 0
	.fileFlags:							db 0
	.fileUnitSize:						db 0
	.interleaveGapSite:					db 0
	.volumeSequenceNumber:				dd 0		        ; in both endian
	.lengthOfFileIdentifier:			db 0
    .fileIdentifier:					times 64 db 0       ; variable length thats why insert buffer after

iso9660_directoryDescriptor:
	.lengthOfDirectoryIdentifier:		db 0
	.extendedAttributeRecordLength:		db 0
	.locationOfExtendLBA:				dd 0
	.directoryNumberOfParent:			dw 0
	.directoryIdentifier:				times 64 db 0       ; variable length thats why insert buffer after

iso9660_volumeDescriptor:
	.type:								db 0 				;   0 / 0x00
	.signature:							times 5 db ' '      ;   1 / 0x01
	.version:							db 0                ;   6 / 0x06
	.null1:								db 0                ;   7 / 0x07
	.systemIdentifier:					times 32 db ' '     ;  39 / 0x27
	.volumeIdentifier:					times 32 db ' '     ;  71 / 0x47
	.null2:								times 8 db 0        ; 103 / 0x67
	.numberOfSectors1:					dd 0                ; 111 / 0x6f
	.numberOfSectors2:					dd 0                ; 115 / 0x73
	.null3:								times 32 db 0       ; 119 / 0x77
	.sizeOfSet:							dd 0                ; 151 / 0x97
	.sequenceNumber:					dd 0                ; 155 /
	.sizeOfSectors:						dd 0                ; 159 /
	.sizeOfPathTable1:					dd 0                ; 163 /
	.sizeOfPathTable2:					dd 0                ; 167 /
	.sectorOfPathTableLE1:				dd 0                ; 171 /
	.sectorOfPathTableLE2:				dd 0                ; 175 /
	.sectorOfPathTableBE1:				dd 0                ; 179 /
	.sectorOfPathTableBE2:				dd 0                ; 183 /
	.rootDirectoryEntry:				times 34 db 0       ; 187 /
	.volumeSetIdentifier:				times 128 db 0      ; 221 /
	.producerSetIdentifier:				times 128 db 0      ; 349 /
	.preparerSetIdentifier:				times 128 db 0      ; 477 /
	.applicationSetIdentifier:			times 128 db 0      ; 605 /
	.copyrightIdentifier:				times 38 db 0       ; 733 /
	.abstractFileIdentifier:			times 36 db 0       ; 771 /
	.bibliographicalFileIdentifier:		times 37 db 0       ; 807 /
	.dateOfCreation:					times 17 db 0       ; 844 /
	.dateOfModifying:					times 17 db 0       ; 861 /
	.dateOfExpiring:					times 17 db 0       ; 878 /
	.dateOfEffective:					times 17 db 0       ; 895 /
	.one:								db 1                ; 912 /
	.zero1:								db 0                ; 913 /
;	.applicationUseReserved:			times 512 db 0
;	.zero2:								times 653 db 0


iso9660_itemEntry:
	.lengthOfEntry:						db 0
	.sectorCountExtendedAttribute:		db 0
	.firstSectorOfData:					times 8 db 0
	.sizeOfData:							times 8 db 0
	.creationYear:						db 0
	.creationMonth:						db 0
	.creationDay:						db 0
	.creationHour:						db 0
	.creationMinute:						db 0
	.creationSecond:						db 0
	.gmtDifference:						db 0
	.flags:								db 0
	.sizeOfUnitInterleaveFiles:			db 0
	.distanceBetweenInterlFileBlocks:	db 0
	.volumeSequenceNumberXE:				times 4 db 0
	.lengthOfIdentifier:					db 0
	.identiferAndRestBuffer:				times 64 db 0
