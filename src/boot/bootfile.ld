ENTRY(main)
SECTIONS {
	. = 0x00100000;
	.text : { *(.text) }
	. = 0x8000000;
	.data : { *(.data) }
	.bss : { *(.bss) }
}