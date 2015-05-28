;volume descriptor

iso9660_fileDescriptor:
	.lengthOfDirectoryRecord:			db 0
	.extendedAttributeRecordLength:		db 0
	.locationOfExtendLBA1:				dd 0		; in both endian
	.locationOfExtendLBA2:				dd 0		; in both endian
	.dataLength1:						dd 0		; in both endian
	.dataLength2:						dd 0		; in both endian
	.recordingDate:						times 7 db 0
	.fileFlags:							db 0
	.fileUnitSize:						db 0
	.interleaveGapSite:					db 0
	.volumeSequenceNumber:				dd 0		; in both endian
	.lengthOfFileIdentifier:			db 0
	.fileIdentifier:					times 64	db 0			; variable length thats why insert buffer after

iso9660_directoryDescriptor:
	.lengthOfDirectoryIdentifier:		db 0
	.extendedAttributeRecordLength:		db 0
	.locationOfExtendLBA:				dd 0		
	.directoryNumberOfParent:			dw 0		
	.directoryIdentifier:				times 64	db 0				; variable length thats why insert buffer after

iso9660_volumeDescriptor:				
	.type:								db 0 				; starting with type
	.signature:							times 5 db ' '
	.version:							db 0
	.null1:								db 0
	.systemIdentifier:					times 32 db ' '
	.volumeIdentifier:					times 32 db ' '
	.null2:								times 8 db 0
	.numberOfSectors1:					dd 0
	.numberOfSectors2:					dd 0
	.null3:								times 32 db 0
	.sizeOfSet:							dd 0
	.sequenceNumber:					dd 0
	.sizeOfSectors:						dd 0
	.sizeOfPathTable1:					dd 0
	.sizeOfPathTable2:					dd 0
	.sectorOfPathTableLE1:				dd 0
	.sectorOfPathTableLE2:				dd 0
	.sectorOfPathTableBE1:				dd 0
	.sectorOfPathTableBE2:				dd 0
	.rootDirectoryEntry:				times 34 db 0
	.volumeSetIdentifier:				times 128 db 0
	.producerSetIdentifier:				times 128 db 0
	.preparerSetIdentifier:				times 128 db 0
	.applicationSetIdentifier:			times 128 db 0
	.copyrightIdentifier:				times 38 db 0
	.abstractFileIdentifier:			times 36 db 0
	.bibliographicalFileIdentifier:		times 37 db 0
	.dateOfCreation:					times 17 db 0
	.dateOfModifying:					times 17 db 0
	.dateOfExpiring:					times 17 db 0
	.dateOfEffective:					times 17 db 0
	.one:								db 1
	.zero1:								db 0
;	.applicationUseReserved:			times 512 db 0
;	.zero2:								times 653 db 0
	

iso9660_itemEntry:
	.lengthOfEntry						db 0
	.sectorCountExtendedAttribute		db 0
	.firstSectorOfData					times 8 db 0
	.sizeOfData							times 8 db 0
	.creationYear						db 0
	.creationMonth						db 0
	.creationDay						db 0
	.creationHour						db 0
	.creationMinute						db 0
	.creationSecond						db 0
	.gmtDifference						db 0
	.flags								db 0
	.sizeOfUnitInterleaveFiles			db 0
	.distanceBetweenInterlFileBlocks	db 0
	.volumeSequenceNumberXE				times 4 db 0
	.lengthOfIdentifier					db 0
	.identiferAndRestBuffer				times 64 db 0
