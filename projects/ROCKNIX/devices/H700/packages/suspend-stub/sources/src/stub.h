/* SPDX-License-Identifier: GPL-2.0+ */
#ifndef STUB_H
#define STUB_H

#include <asm/arch/cpu.h>
#include <asm/arch/dram.h>
#include <sunxi_suspend_params.h>

/* Progress codes, mirrored into an RTC general purpose register */
#define STAGE_ENTER		0x10
#define STAGE_BAD_CONFIG	0x1e
#define STAGE_SR_ENTER		0x20
#define STAGE_SR_FAILED		0x2e
#define STAGE_CLOCKS_DOWN	0x30
#define STAGE_WFI		0x40
#define STAGE_CLOCKS_UP		0x50
#define STAGE_DRAM_INIT		0x60
/* 0x61..0x68: markers inside the U-Boot DRAM driver, see prepare_dram.py */
#define STAGE_DRAM_DONE		0x69
#define STAGE_MEM_RESTORED	0x6a
#define STAGE_DRAM_FAILED	0xe0
#define STAGE_EXCEPTION		0xee
#define STAGE_RESUME		0x70

/* RTC general purpose registers used for debugging, readable after reboot */
#define STUB_RTC_STAGE_REG	(SUNXI_RTC_BASE + 0x10c)
#define STUB_RTC_WAKE_REG	(SUNXI_RTC_BASE + 0x110)
#define STUB_RTC_CFG_REG	(SUNXI_RTC_BASE + 0x114)	/* dram_config word */
#define STUB_RTC_AWAIT_REG	(SUNXI_RTC_BASE + 0x120)	/* register being awaited */
#define STUB_RTC_AWAIT_CNT_REG	(SUNXI_RTC_BASE + 0x124)	/* awaits done, bit 31: timeout */
#define STUB_RTC_EXC_ESR_REG	(SUNXI_RTC_BASE + 0x128)	/* written by start.S */
#define STUB_RTC_EXC_ELR_REG	(SUNXI_RTC_BASE + 0x12c)	/* written by start.S */
#define STUB_RTC_SIZE_MB_REG	(SUNXI_RTC_BASE + 0x130)
#define STUB_RTC_FAIL_REG	(SUNXI_RTC_BASE + 0x134)	/* first failing register */
#define STUB_RTC_FAIL_INFO_REG	(SUNXI_RTC_BASE + 0x138)	/* stage << 16 | kind */
#define STUB_RTC_RESULT_REG	(SUNXI_RTC_BASE + 0x13c)	/* final result code */

/* kinds for STUB_RTC_FAIL_INFO_REG */
#define FAIL_AWAIT_TIMEOUT	1
#define FAIL_POLL_TIMEOUT	2
#define FAIL_INIT_FALSE		3

void stub_fail_record(unsigned long reg, u32 kind);

extern struct sunxi_suspend_params stub_params;
extern bool dram_timeout;

/* start.S */
u64 read_cntpct(void);
u64 read_cntfrq(void);
u64 read_scr_el3(void);
void write_scr_el3(u64 val);
void cpu_wfi(void);

/* lib.c */
void stage(u32 code);
void dbg_puts(const char *s);
void dbg_hex(u32 val);
bool wait_reg(unsigned long reg, u32 mask, u32 val, unsigned long timeout_us);
void wdog_save_disable(void);
void wdog_arm(void);
void wdog_restore(void);

/* clock.c */
void clocks_down(void);
void clocks_up(void);
void cpu_clock_restore(void);

/* dram_sr.c */
bool dram_read_config(struct dram_config *config);
u32 dram_config_word(const struct dram_config *config);
bool dram_enter_selfrefresh(void);
bool dram_enter_selfrefresh_keep_phy(void);
bool dram_exit_selfrefresh_keep_phy(void);

/* dram_sun50i_h616.c (generated from U-Boot) */
bool sunxi_dram_resume_init(const struct dram_config *config);
unsigned long mctl_calc_size(const struct dram_config *config);

#endif /* STUB_H */
