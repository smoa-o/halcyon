MPROC_BA = 0x100000;

ENTRY(kmain)

SECTIONS {
	. = MPROC_BA;

	.text : {
		*(.text)
	}

	.rodata : {
		*(.rodata)
	}

	.data : {
		*(.data)
	}

	.bss : {
		*(COMMON)
		*(.bss)
	}
}
