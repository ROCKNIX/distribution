// SPDX-License-Identifier: GPL-2.0+
/*
 * Clock gating around WFI, following the Anbernic/Allwinner BSP standby
 * code ("universal standby" with wake-up sources): CPU, APB1 and APB2 are
 * moved to the 32 kHz clock and PLL_CPUX is switched off. PLL_PERI0 and
 * the 24 MHz oscillator stay on.
 */

#include <asm/io.h>
#include <asm/arch/clock.h>
#include "stub.h"

#define CCU(off)		(SUNXI_CCM_BASE + (off))
#define CLK_SRC_MASK		(0x3 << 24)
#define CLK_SRC_OSC24M		(0x0 << 24)
#define CLK_SRC_32K		(0x1 << 24)

/* R_PRCM PLL LDO control, written with key 0xa7 like the BSP (inferred) */
#define PRCM_PLL_LDO_REG	(SUNXI_PRCM_BASE + 0x244)
#define PRCM_PLL_LDO_KEY	(0xa7U << 24)

static struct {
	u32 pll_cpux;
	u32 cpu_axi;
	u32 apb1;
	u32 apb2;
} saved;

void clocks_down(void)
{
	saved.pll_cpux = readl(CCU(CCU_H6_PLL1_CFG));
	saved.cpu_axi = readl(CCU(CCU_H6_CPU_AXI_CFG));
	saved.apb1 = readl(CCU(CCU_H6_APB1_CFG));
	saved.apb2 = readl(CCU(CCU_H6_APB2_CFG));

	/* Move the CPU off PLL_CPUX first, while the 24 MHz clock is known good */
	clrsetbits_le32(CCU(CCU_H6_CPU_AXI_CFG), CLK_SRC_MASK, CLK_SRC_OSC24M);
	udelay(100);

	clrsetbits_le32(CCU(CCU_H6_APB1_CFG), CLK_SRC_MASK, CLK_SRC_32K);
	clrsetbits_le32(CCU(CCU_H6_APB2_CFG), CLK_SRC_MASK, CLK_SRC_32K);
	clrsetbits_le32(CCU(CCU_H6_CPU_AXI_CFG), CLK_SRC_MASK, CLK_SRC_32K);

	clrbits_le32(CCU(CCU_H6_PLL1_CFG), CCM_PLL_CTRL_EN | CCM_PLL_LOCK_EN);

	writel((readl(PRCM_PLL_LDO_REG) & 0x00ffffff) | PRCM_PLL_LDO_KEY,
	       PRCM_PLL_LDO_REG);
}

/* Everything back except the CPU clock, which stays on OSC24M during DRAM init */
void clocks_up(void)
{
	writel(readl(PRCM_PLL_LDO_REG) & 0x00ffffff, PRCM_PLL_LDO_REG);

	clrsetbits_le32(CCU(CCU_H6_CPU_AXI_CFG), CLK_SRC_MASK, CLK_SRC_OSC24M);

	writel(saved.pll_cpux | CCM_PLL_CTRL_EN | CCM_PLL_LOCK_EN,
	       CCU(CCU_H6_PLL1_CFG));
	wait_reg(CCU(CCU_H6_PLL1_CFG), CCM_PLL_LOCK, CCM_PLL_LOCK, 100000);

	writel(saved.apb2, CCU(CCU_H6_APB2_CFG));
	writel(saved.apb1, CCU(CCU_H6_APB1_CFG));
	udelay(1000);
}

void cpu_clock_restore(void)
{
	writel(saved.cpu_axi, CCU(CCU_H6_CPU_AXI_CFG));
	udelay(100);
}
