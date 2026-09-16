/* SPDX-License-Identifier: GPL-2.0+ */
#ifndef STUB_ASM_ARCH_DRAM_DW_HELPERS_H
#define STUB_ASM_ARCH_DRAM_DW_HELPERS_H

#include <asm/io.h>
#include <asm/arch/dram.h>

bool mctl_core_init(const struct dram_para *para,
		    const struct dram_config *config);
void mctl_auto_detect_rank_width(const struct dram_para *para,
				 struct dram_config *config);
void mctl_auto_detect_dram_size(const struct dram_para *para,
				struct dram_config *config);
unsigned long mctl_calc_size(const struct dram_config *config);

#endif /* STUB_ASM_ARCH_DRAM_DW_HELPERS_H */
