/* SPDX-License-Identifier: GPL-2.0+ */

OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_head)

MEMORY
{
	/* SRAM A1: 32 KiB, unused after boot when BL31 lives in DRAM */
	sram (rwx) : ORIGIN = 0x00020000, LENGTH = 0x8000
}

STACK_SIZE = 0x1000;

SECTIONS
{
	.text : {
		__stub_start = .;
		KEEP(*(.head))
		. = 0x10;
		KEEP(*(.params))
		*(.text .text.*)
		*(.rodata .rodata.*)
		*(.data .data.*)
		. = ALIGN(8);
		__stub_end = .;
	} > sram

	.bss (NOLOAD) : {
		__bss_start = .;
		*(.bss .bss.* COMMON)
		. = ALIGN(8);
		__bss_end = .;
	} > sram

	__stack_top = ORIGIN(sram) + LENGTH(sram);
	__stub_size = __stub_end - __stub_start;

	ASSERT(__bss_end <= __stack_top - STACK_SIZE,
	       "suspend stub does not fit into SRAM A1")

	/DISCARD/ : {
		*(.comment)
		*(.note*)
		*(.eh_frame*)
	}
}
