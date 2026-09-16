// SPDX-License-Identifier: GPL-2.0+
/*
 * H616 DRAM self-refresh entry and configuration read-back.
 *
 * The entry sequence follows the Anbernic/Allwinner BSP standby code: stop
 * the MBUS masters, request software self-refresh, latch the DRAM pads,
 * shut the DFI down and gate the controller, PHY and PLL_DDR clocks.
 */

#include <asm/io.h>
#include <asm/arch/clock.h>
#include <asm/arch/prcm.h>
#include "stub.h"

#define COM(off)		(SUNXI_DRAM_COM_BASE + (off))
#define CTL(off)		(SUNXI_DRAM_CTL0_BASE + (off))
#define CCU(off)		(SUNXI_CCM_BASE + (off))

#define COM_MAER0		0x020
#define COM_MAER1		0x024
#define COM_MAER2		0x028

#define CTL_MSTR		0x000
#define CTL_STAT		0x004
#define CTL_CLKEN		0x00c
#define CTL_PWRCTL		0x030
#define CTL_DFIMISC		0x1b0
#define CTL_DFISTAT		0x1bc
#define CTL_ADDRMAP1		0x204
#define CTL_ADDRMAP6		0x218
#define CTL_ADDRMAP7		0x21c
#define CTL_SWCTL		0x320
#define CTL_SWSTAT		0x324

#define MSTR_DEVICE_MASK	0x3f
#define MSTR_BUSWIDTH_HALF_BIT	BIT(12)
#define MSTR_RANKS_SHIFT	24

#define PWRCTL_SELFREF_EN	BIT(0)
#define PWRCTL_SELFREF_SW	BIT(5)

#define STAT_MODE_MASK		0x7
#define STAT_MODE_NORMAL	0x1
#define STAT_MODE_SELFREF	0x3

#define DRAM_PAD_HOLD_REG	(SUNXI_RTC_BASE + 0x1f4)

static unsigned int count_used_bytes(u32 reg, unsigned int bytes)
{
	unsigned int i, n = 0;

	for (i = 0; i < bytes; i++)
		if (((reg >> (8 * i)) & 0xff) != 0x0f)
			n++;

	return n;
}

/*
 * Rebuild the dram_config that SPL detected at boot from the controller
 * registers (inverse of mctl_set_addrmap()), and make sure the controller
 * runs the memory type and clock this stub was built for.
 */
bool dram_read_config(struct dram_config *config)
{
	u32 mstr = readl(CTL(CTL_MSTR));
	u32 pll5 = readl(CCU(CCU_H6_PLL5_CFG));
	u32 expected_n = CONFIG_DRAM_CLK * 2 / 24;
	unsigned int cols;

	if ((mstr & MSTR_DEVICE_MASK) != STUB_MSTR_DEVICETYPE)
		return false;
	if (((pll5 >> 8) & 0xff) + 1 != expected_n)
		return false;
	if ((readl(CTL(CTL_STAT)) & STAT_MODE_MASK) != STAT_MODE_NORMAL)
		return false;

	config->ranks = (((mstr >> MSTR_RANKS_SHIFT) & 0x3) == 0x3) ? 2 : 1;
	config->bus_full_width = !(mstr & MSTR_BUSWIDTH_HALF_BIT);

	cols = (readl(CTL(CTL_ADDRMAP1)) & 0x1f) + 2;
	if (!config->bus_full_width)
		cols += 1;
	config->cols = cols;

	config->rows = 12 + count_used_bytes(readl(CTL(CTL_ADDRMAP6)), 4) +
		       count_used_bytes(readl(CTL(CTL_ADDRMAP7)), 2);

	if (config->cols < 7 || config->cols > 12 ||
	    config->rows < 13 || config->rows > 18)
		return false;

	return true;
}

u32 dram_config_word(const struct dram_config *config)
{
	return config->cols | config->rows << 8 | config->ranks << 16 |
	       config->bus_full_width << 24;
}

static u32 keep_maer[3];
static u32 keep_pwrctl;

/*
 * Self-refresh with the controller and PHY left clocked and out of reset.
 * No re-training is needed on exit, at the cost of keeping PLL_DDR and the
 * DRAM PHY powered during sleep.
 */
bool dram_enter_selfrefresh_keep_phy(void)
{
	keep_maer[0] = readl(COM(COM_MAER0));
	keep_maer[1] = readl(COM(COM_MAER1));
	keep_maer[2] = readl(COM(COM_MAER2));
	keep_pwrctl = readl(CTL(CTL_PWRCTL));

	writel(0, COM(COM_MAER0));
	writel(0, COM(COM_MAER1));
	writel(0, COM(COM_MAER2));

	setbits_le32(CTL(CTL_PWRCTL), PWRCTL_SELFREF_SW | PWRCTL_SELFREF_EN);
	if (!wait_reg(CTL(CTL_STAT), STAT_MODE_MASK, STAT_MODE_SELFREF, 100000)) {
		writel(keep_pwrctl, CTL(CTL_PWRCTL));
		wait_reg(CTL(CTL_STAT), STAT_MODE_MASK, STAT_MODE_NORMAL, 100000);
		writel(keep_maer[0], COM(COM_MAER0));
		writel(keep_maer[1], COM(COM_MAER1));
		writel(keep_maer[2], COM(COM_MAER2));
		return false;
	}

	return true;
}

bool dram_exit_selfrefresh_keep_phy(void)
{
	writel(keep_pwrctl & ~(PWRCTL_SELFREF_SW | PWRCTL_SELFREF_EN),
	       CTL(CTL_PWRCTL));
	if (!wait_reg(CTL(CTL_STAT), STAT_MODE_MASK, STAT_MODE_NORMAL, 1000000)) {
		stub_fail_record(CTL(CTL_STAT), FAIL_AWAIT_TIMEOUT);
		return false;
	}

	writel(keep_pwrctl, CTL(CTL_PWRCTL));
	writel(keep_maer[0], COM(COM_MAER0));
	writel(keep_maer[1], COM(COM_MAER1));
	writel(keep_maer[2], COM(COM_MAER2));

	return true;
}

bool dram_enter_selfrefresh(void)
{
	u32 maer0 = readl(COM(COM_MAER0));
	u32 maer1 = readl(COM(COM_MAER1));
	u32 maer2 = readl(COM(COM_MAER2));

	/* No more bus masters */
	writel(0, COM(COM_MAER0));
	writel(0, COM(COM_MAER1));
	writel(0, COM(COM_MAER2));

	setbits_le32(CTL(CTL_PWRCTL), PWRCTL_SELFREF_SW | PWRCTL_SELFREF_EN);
	if (!wait_reg(CTL(CTL_STAT), STAT_MODE_MASK, STAT_MODE_SELFREF, 100000)) {
		/* Back out: DRAM is still refreshed by the controller */
		clrbits_le32(CTL(CTL_PWRCTL), PWRCTL_SELFREF_SW | PWRCTL_SELFREF_EN);
		wait_reg(CTL(CTL_STAT), STAT_MODE_MASK, STAT_MODE_NORMAL, 100000);
		writel(maer0, COM(COM_MAER0));
		writel(maer1, COM(COM_MAER1));
		writel(maer2, COM(COM_MAER2));
		return false;
	}

	/* Hold the DRAM pads (CKE low) while the PHY is reset and unclocked */
	clrbits_le32(DRAM_PAD_HOLD_REG, BIT(0));

	/* Shut the DFI interface down */
	writel(0, CTL(CTL_SWCTL));
	clrsetbits_le32(CTL(CTL_DFIMISC), BIT(0), 0x1f20);
	writel(1, CTL(CTL_SWCTL));
	wait_reg(CTL(CTL_DFISTAT), BIT(0), 0, 100000);

	writel(0, CTL(CTL_CLKEN));

	/* Gate everything on the DRAM side */
	clrbits_le32(CCU(CCU_H6_PLL5_CFG), CCM_PLL_CTRL_EN);
	clrbits_le32(CCU(CCU_H6_DRAM_CLK_CFG), DRAM_MOD_RESET);
	clrbits_le32(CCU(CCU_H6_DRAM_GATE_RESET), BIT(RESET_SHIFT) | BIT(GATE_SHIFT));
	clrbits_le32(CCU(CCU_H6_MBUS_CFG), MBUS_ENABLE | MBUS_RESET);

	return true;
}
