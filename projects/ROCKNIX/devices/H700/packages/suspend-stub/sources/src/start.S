/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Entered from BL31 at EL3 with the MMU and caches off and all exceptions
 * masked. Returns to BL31's warm boot entry point.
 */

#define RESUME_ENTRY_OFFSET	0x10	/* offsetof(struct sunxi_suspend_params, resume_entry) */

	.section .head, "ax"
	.globl	_head
_head:
	b	_start
	.word	0
	.quad	__stub_size			/* image size, from stub.lds */


	.text
	.globl	_start
_start:
	msr	daifset, #0xf
	/* BL31's vectors live in DRAM, which is unusable while we run */
	ldr	x0, =stub_vectors
	msr	vbar_el3, x0
	isb
	/* take SErrors too, so bus faults get recorded instead of hanging */
	msr	daifclr, #4
	ldr	x0, =__stack_top
	mov	sp, x0

	ldr	x0, =__bss_start
	ldr	x1, =__bss_end
1:	cmp	x0, x1
	b.hs	2f
	str	xzr, [x0], #8
	b	1b
2:
	bl	stub_main

	ldr	x0, =stub_params
	ldr	x0, [x0, #RESUME_ENTRY_OFFSET]
	br	x0

	.globl	read_cntpct
read_cntpct:
	mrs	x0, cntpct_el0
	ret

	.globl	read_cntfrq
read_cntfrq:
	mrs	x0, cntfrq_el0
	ret

	.globl	read_scr_el3
read_scr_el3:
	mrs	x0, scr_el3
	ret

	.globl	write_scr_el3
write_scr_el3:
	msr	scr_el3, x0
	isb
	ret

	.globl	cpu_wfi
cpu_wfi:
	dsb	sy		/* Complete MMIO writes before entering low power. */
	wfi
	ret

/*
 * Any exception taken while the stub runs: record ESR/ELR and stage 0xee in
 * RTC general purpose registers (they survive a reset), then reset through
 * the watchdog. Uses no stack.
 */
	.align	11
	.globl	stub_vectors
stub_vectors:
	.rept	16
	b	stub_exception
	.align	7
	.endr

stub_exception:
	mrs	x0, esr_el3
	ldr	x1, =0x07000128
	str	w0, [x1]
	mrs	x0, elr_el3
	ldr	x1, =0x0700012c
	str	w0, [x1]
	mov	w0, #0xee
	ldr	x1, =0x0700010c
	str	w0, [x1]
	mov	w0, #1			/* whole system reset */
	ldr	x1, =0x030090b4		/* WDOG0 CFG */
	str	w0, [x1]
	mov	w0, #1			/* 0.5 s, enable */
	ldr	x1, =0x030090b8		/* WDOG0 MODE */
	str	w0, [x1]
1:	wfi
	b	1b
