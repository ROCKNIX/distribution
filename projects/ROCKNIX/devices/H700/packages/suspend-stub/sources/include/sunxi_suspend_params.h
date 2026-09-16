/* SPDX-License-Identifier: BSD-3-Clause */
/*
 * Interface between TF-A BL31 and the H616 SRAM suspend stub.
 *
 * The stub is linked to run from SRAM A1 (0x20000). BL31 copies the stub
 * image there, fills in the "in" fields of the parameter block located at
 * SUNXI_SUSPEND_PARAMS_OFFSET, turns the MMU off and jumps to the start of
 * the image. The stub puts DRAM into self-refresh, gates clocks, waits for
 * an interrupt, restores DRAM and jumps to resume_entry. SRAM keeps its
 * contents, so BL31 can read the "out" fields after resume.
 */

#ifndef SUNXI_SUSPEND_PARAMS_H
#define SUNXI_SUSPEND_PARAMS_H

#define SUNXI_SUSPEND_STUB_BASE		0x00020000
#define SUNXI_SUSPEND_PARAMS_OFFSET	0x10

#define SUNXI_SUSPEND_MAGIC		0x50535553	/* "SUSP" */
#define SUNXI_SUSPEND_VERSION		1

/* flags (in) */
#define SUNXI_SUSPEND_FLAG_DEBUG_UART	(1 << 0)

/* status (out) */
#define SUNXI_SUSPEND_STATUS_NONE	0	/* stub did not run */
#define SUNXI_SUSPEND_STATUS_OK		1	/* went through self-refresh */
#define SUNXI_SUSPEND_STATUS_ERR_CONFIG	2	/* DRAM state unexpected, skipped */
#define SUNXI_SUSPEND_STATUS_ERR_SR	3	/* self-refresh entry failed, skipped */

#ifndef __ASSEMBLER__
#include <stdint.h>

struct sunxi_suspend_params {
	uint32_t magic;		/* build: SUNXI_SUSPEND_MAGIC */
	uint32_t version;	/* build: SUNXI_SUSPEND_VERSION */
	uint32_t dram_type;	/* build: DRAM type the stub was built for */
	uint32_t dram_clk;	/* build: DRAM clock in MHz */
	uint64_t resume_entry;	/* in: BL31 warm boot entry point */
	uint32_t flags;		/* in: SUNXI_SUSPEND_FLAG_* */
	uint32_t status;	/* out: SUNXI_SUSPEND_STATUS_* */
	uint32_t stage;		/* out: last progress code */
	uint32_t wake_irq;	/* out: first pending GIC interrupt after WFI */
	uint64_t dram_size;	/* out: detected DRAM size in bytes */
	uint32_t dram_cfg;	/* out: cols | rows << 8 | ranks << 16 | full << 24 */
	uint32_t reserved;
};
#endif /* __ASSEMBLER__ */

#endif /* SUNXI_SUSPEND_PARAMS_H */
