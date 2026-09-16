// SPDX-License-Identifier: GPL-2.0+
/*
 * Freestanding helpers for the H616 SRAM suspend stub.
 */

#include <asm/io.h>
#include "stub.h"

#define UART_THR		0x00
#define UART_LSR		0x14
#define UART_LSR_THRE		BIT(5)

#define WDOG_CTRL_REG		(SUNXI_WDOG_BASE + 0x10)
#define WDOG_CTRL_RELOAD	((0xa57 << 1) | BIT(0))
#define WDOG_CFG_REG		(SUNXI_WDOG_BASE + 0x14)
#define WDOG_MODE_REG		(SUNXI_WDOG_BASE + 0x18)
#define WDOG_MODE_EN		BIT(0)
#define WDOG_INTV_16S		(0xb << 4)

bool dram_timeout;

static u32 wdog_cfg_saved;
static u32 wdog_mode_saved;

void *memcpy(void *dst, const void *src, size_t n)
{
	unsigned char *d = dst;
	const unsigned char *s = src;

	while (n--)
		*d++ = *s++;

	return dst;
}

void *memset(void *s, int c, size_t n)
{
	unsigned char *p = s;

	while (n--)
		*p++ = (unsigned char)c;

	return s;
}

static u64 us_to_ticks(unsigned long us)
{
	u64 freq = read_cntfrq();

	if (freq == 0)
		freq = 24000000;

	return (freq * us) / 1000000 + 1;
}

void udelay(unsigned long us)
{
	u64 end = read_cntpct() + us_to_ticks(us);

	while (read_cntpct() < end)
		;
}

bool wait_reg(unsigned long reg, u32 mask, u32 val, unsigned long timeout_us)
{
	u64 end = read_cntpct() + us_to_ticks(timeout_us);

	while ((readl(reg) & mask) != val) {
		if (read_cntpct() > end)
			return false;
	}

	return true;
}

static u32 await_count;

u64 stub_deadline(unsigned long timeout_us)
{
	return read_cntpct() + us_to_ticks(timeout_us);
}

/* Remember only the first failure, together with the stage it happened in. */
void stub_fail_record(unsigned long reg, u32 kind)
{
	if (readl(STUB_RTC_FAIL_INFO_REG) != 0)
		return;

	writel((u32)reg, STUB_RTC_FAIL_REG);
	writel((stub_params.stage << 16) | kind, STUB_RTC_FAIL_INFO_REG);
}

/* For busy loops in the DRAM driver: log and report an expired deadline. */
bool stub_expired(u64 deadline, unsigned long reg)
{
	if (read_cntpct() <= deadline)
		return false;

	dram_timeout = true;
	stub_fail_record(reg, FAIL_POLL_TIMEOUT);

	return true;
}

/*
 * U-Boot's version panics on timeout; here we record it and carry on.
 * Every wait is logged to RTC registers so a hang can be located after the
 * watchdog has reset the board.
 */
void mctl_await_completion(u32 *reg, u32 mask, u32 val)
{
	await_count++;
	writel((u32)(unsigned long)reg, STUB_RTC_AWAIT_REG);
	writel(await_count, STUB_RTC_AWAIT_CNT_REG);

	if (!wait_reg((unsigned long)reg, mask, val, 1000000)) {
		dram_timeout = true;
		stub_fail_record((unsigned long)reg, FAIL_AWAIT_TIMEOUT);
	}
}

void stage(u32 code)
{
	stub_params.stage = code;
	writel(code, STUB_RTC_STAGE_REG);
}

static void dbg_putc(char c)
{
	unsigned int n = 100000;

	while (!(readl(SUNXI_UART0_BASE + UART_LSR) & UART_LSR_THRE) && --n)
		;
	writel(c, SUNXI_UART0_BASE + UART_THR);
}

void dbg_puts(const char *s)
{
	if (!(stub_params.flags & SUNXI_SUSPEND_FLAG_DEBUG_UART))
		return;

	while (*s) {
		if (*s == '\n')
			dbg_putc('\r');
		dbg_putc(*s++);
	}
}

void dbg_hex(u32 val)
{
	static const char digits[] = "0123456789abcdef";
	char buf[11];
	int i;

	buf[0] = '0';
	buf[1] = 'x';
	for (i = 0; i < 8; i++)
		buf[2 + i] = digits[(val >> (28 - 4 * i)) & 0xf];
	buf[10] = '\0';
	dbg_puts(buf);
}

/* The OS watchdog keeps counting during WFI: stop it for the whole sleep. */
void wdog_save_disable(void)
{
	wdog_cfg_saved = readl(WDOG_CFG_REG);
	wdog_mode_saved = readl(WDOG_MODE_REG);

	writel(wdog_mode_saved & ~WDOG_MODE_EN, WDOG_MODE_REG);
}

/* Reset the board if the resume path hangs, instead of draining the battery. */
void wdog_arm(void)
{
	writel(1, WDOG_CFG_REG);
	writel(WDOG_INTV_16S | WDOG_MODE_EN, WDOG_MODE_REG);
	writel(WDOG_CTRL_RELOAD, WDOG_CTRL_REG);
}

/* Hand the watchdog back to the OS as it was, with a fresh timeout. */
void wdog_restore(void)
{
	writel(wdog_mode_saved & ~WDOG_MODE_EN, WDOG_MODE_REG);
	writel(wdog_cfg_saved, WDOG_CFG_REG);
	writel(WDOG_CTRL_RELOAD, WDOG_CTRL_REG);
	writel(wdog_mode_saved, WDOG_MODE_REG);
}

__attribute__((noreturn)) void stub_panic(void)
{
	dbg_puts("stub: fatal, waiting for watchdog reset\n");
	writel(1, WDOG_CFG_REG);
	writel(WDOG_MODE_EN, WDOG_MODE_REG);
	for (;;)
		cpu_wfi();
}
