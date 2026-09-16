// SPDX-License-Identifier: GPL-2.0+
/*
 * Allwinner H616/H700 SRAM suspend stub.
 *
 * Runs from SRAM A1 at EL3 with the MMU off, entered from TF-A's
 * pwr_domain_pwr_down_wfi() for PSCI SYSTEM_SUSPEND. It follows the
 * "universal standby" path of the Anbernic stock firmware: DRAM goes into
 * self-refresh, clocks are gated, the boot CPU waits for an interrupt and
 * DRAM is brought back before returning to BL31's warm boot entry.
 *
 * STUB_DRAM_KEEP_PHY=1: the DRAM controller and PHY stay clocked during
 *   sleep; resume only leaves self-refresh.
 * STUB_DRAM_KEEP_PHY=0: controller, PHY and PLL_DDR are shut down like the
 *   BSP does; resume re-initialises and re-trains them (U-Boot DRAM driver).
 */

#include <asm/io.h>
#include "stub.h"

#define GICD(off)		(SUNXI_GICD_BASE + (off))
#define GICD_TYPER		0x004
#define GICD_ISENABLER(n)	(0x100 + 4 * (n))
#define GICD_ISPENDR(n)		(0x200 + 4 * (n))

#define SCR_FIQ_BIT		BIT(2)
#define SCR_IRQ_BIT		BIT(1)

/* Memory the PHY training may overwrite, saved like the BSP does */
#define SAVE_WORDS		0x50

_Static_assert(offsetof(struct sunxi_suspend_params, resume_entry) == 0x10,
	       "start.S expects resume_entry at offset 0x10");

struct sunxi_suspend_params stub_params
	__attribute__((section(".params"), used)) = {
	.magic		= SUNXI_SUSPEND_MAGIC,
	.version	= SUNXI_SUSPEND_VERSION,
	.dram_type	= STUB_DRAM_TYPE,
	.dram_clk	= CONFIG_DRAM_CLK,
};

bool sunxi_dram_resume = true;

static u32 gic_first_pending(void)
{
	unsigned int n, lines = ((readl(GICD(GICD_TYPER)) & 0x1f) + 1);

	for (n = 0; n < lines; n++) {
		u32 pend = readl(GICD(GICD_ISPENDR(n))) &
			   readl(GICD(GICD_ISENABLER(n)));

		if (pend)
			return 32 * n + __builtin_ctz(pend);
	}

	return 1023;
}

static void wait_for_wakeup(void)
{
	u64 scr = read_scr_el3();

	/* Route IRQ/FIQ to EL3 so a pending interrupt ends WFI (still masked) */
	write_scr_el3(scr | SCR_IRQ_BIT | SCR_FIQ_BIT);
	cpu_wfi();
	write_scr_el3(scr);
}

static void debug_regs_clear(void)
{
	static const unsigned long regs[] = {
		STUB_RTC_AWAIT_REG, STUB_RTC_AWAIT_CNT_REG,
		STUB_RTC_EXC_ESR_REG, STUB_RTC_EXC_ELR_REG,
		STUB_RTC_FAIL_REG, STUB_RTC_FAIL_INFO_REG,
		STUB_RTC_RESULT_REG,
	};
	unsigned int i;

	for (i = 0; i < ARRAY_SIZE(regs); i++)
		writel(0, regs[i]);
}

static __attribute__((noreturn)) void resume_failed(void)
{
	writel(STAGE_DRAM_FAILED, STUB_RTC_RESULT_REG);
	stub_panic();
}

#if STUB_DRAM_KEEP_PHY

static bool dram_suspend(const struct dram_config *config)
{
	return dram_enter_selfrefresh_keep_phy();
}

static void dram_resume(const struct dram_config *config)
{
	if (!dram_exit_selfrefresh_keep_phy())
		resume_failed();
	stage(STAGE_DRAM_DONE);
}

#else /* !STUB_DRAM_KEEP_PHY */

static u32 save_lo[SAVE_WORDS];
static u32 save_hi[SAVE_WORDS];
static unsigned long save_hi_addr;

static bool dram_suspend(const struct dram_config *config)
{
	save_hi_addr = CFG_SYS_SDRAM_BASE + mctl_calc_size(config) / 2;

	memcpy(save_lo, (void *)CFG_SYS_SDRAM_BASE, sizeof(save_lo));
	memcpy(save_hi, (void *)save_hi_addr, sizeof(save_hi));

	return dram_enter_selfrefresh();
}

static void dram_resume(const struct dram_config *config)
{
	dram_timeout = false;
	if (!sunxi_dram_resume_init(config)) {
		stub_fail_record(0, FAIL_INIT_FALSE);
		resume_failed();
	}
	if (dram_timeout)
		resume_failed();
	stage(STAGE_DRAM_DONE);

	memcpy((void *)CFG_SYS_SDRAM_BASE, save_lo, sizeof(save_lo));
	memcpy((void *)save_hi_addr, save_hi, sizeof(save_hi));
	stage(STAGE_MEM_RESTORED);
}

#endif /* STUB_DRAM_KEEP_PHY */

void stub_main(void)
{
	struct dram_config config;
	unsigned long size;

	stub_params.status = SUNXI_SUSPEND_STATUS_NONE;
	debug_regs_clear();
	stage(STAGE_ENTER);
	dbg_puts("\nstub: suspend\n");

	if (!dram_read_config(&config)) {
		stub_params.status = SUNXI_SUSPEND_STATUS_ERR_CONFIG;
		stage(STAGE_BAD_CONFIG);
		writel(STAGE_BAD_CONFIG, STUB_RTC_RESULT_REG);
		dbg_puts("stub: unexpected DRAM state, skipping\n");
		return;
	}

	size = mctl_calc_size(&config);
	stub_params.dram_size = size;
	stub_params.dram_cfg = dram_config_word(&config);
	writel(stub_params.dram_cfg, STUB_RTC_CFG_REG);
	writel(size >> 20, STUB_RTC_SIZE_MB_REG);

	wdog_save_disable();

	stage(STAGE_SR_ENTER);
	if (!dram_suspend(&config)) {
		wdog_restore();
		stub_params.status = SUNXI_SUSPEND_STATUS_ERR_SR;
		stage(STAGE_SR_FAILED);
		writel(STAGE_SR_FAILED, STUB_RTC_RESULT_REG);
		dbg_puts("stub: self-refresh entry failed, skipping\n");
		return;
	}

	dbg_puts("stub: DRAM in self-refresh\n");
	stage(STAGE_CLOCKS_DOWN);
	clocks_down();

	stage(STAGE_WFI);
	wait_for_wakeup();

	clocks_up();
	stage(STAGE_CLOCKS_UP);

	stub_params.wake_irq = gic_first_pending();
	writel(stub_params.wake_irq, STUB_RTC_WAKE_REG);
	dbg_puts("stub: wake-up, irq ");
	dbg_hex(stub_params.wake_irq);
	dbg_puts("\n");

	wdog_arm();
	stage(STAGE_DRAM_INIT);
	dram_resume(&config);
	wdog_restore();

	cpu_clock_restore();

	stub_params.status = SUNXI_SUSPEND_STATUS_OK;
	stage(STAGE_RESUME);
	writel(STAGE_RESUME, STUB_RTC_RESULT_REG);
	dbg_puts("stub: DRAM back, returning to BL31\n");
}
