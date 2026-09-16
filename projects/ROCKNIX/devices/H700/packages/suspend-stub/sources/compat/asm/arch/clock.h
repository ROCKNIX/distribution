/* SPDX-License-Identifier: GPL-2.0+ */
/* The subset of U-Boot's clock_sun50i_h6.h used by the H616 DRAM driver. */
#ifndef STUB_ASM_ARCH_CLOCK_H
#define STUB_ASM_ARCH_CLOCK_H

#define CCU_H6_PLL1_CFG			0x000
#define CCU_H6_PLL5_CFG			0x010
#define CCU_H6_CPU_AXI_CFG		0x500
#define CCU_H6_PSI_AHB1_AHB2_CFG	0x510
#define CCU_H6_AHB3_CFG			0x51c
#define CCU_H6_APB1_CFG			0x520
#define CCU_H6_APB2_CFG			0x524
#define CCU_H6_MBUS_CFG			0x540
#define CCU_H6_DRAM_CLK_CFG		0x800
#define CCU_H6_DRAM_GATE_RESET		0x80c

#define CCM_PLL_CTRL_EN			BIT(31)
#define CCM_PLL_LOCK_EN			BIT(29)
#define CCM_PLL_LOCK			BIT(28)
#define CCM_PLL_OUT_EN			BIT(27)
#define CCM_PLL5_CTRL_N(n)		(((n) - 1) << 8)

#define MBUS_ENABLE			BIT(31)
#define MBUS_RESET			BIT(30)

#define RESET_SHIFT			(16)
#define GATE_SHIFT			(0)

#define DRAM_MOD_RESET			BIT(30)
#define DRAM_CLK_SRC_PLL5		(0 << 24)

#endif /* STUB_ASM_ARCH_CLOCK_H */
