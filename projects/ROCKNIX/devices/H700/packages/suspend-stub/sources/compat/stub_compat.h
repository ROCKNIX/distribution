/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Minimal freestanding environment so U-Boot's H616 DRAM driver can be
 * compiled unmodified (apart from the resume hooks) into the SRAM stub.
 */

#ifndef STUB_COMPAT_H
#define STUB_COMPAT_H

#ifndef __ASSEMBLY__
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef int32_t s32;
typedef unsigned long ulong;

#define BIT(nr)			(1UL << (nr))
#define GENMASK(h, l)		(((~0UL) << (l)) & (~0UL >> (63 - (h))))
#define ARRAY_SIZE(a)		(sizeof(a) / sizeof((a)[0]))
#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))

#define max(x, y) ({ __typeof__(x) _mx = (x); __typeof__(y) _my = (y); _mx > _my ? _mx : _my; })
#define min(x, y) ({ __typeof__(x) _mx = (x); __typeof__(y) _my = (y); _mx < _my ? _mx : _my; })

#define check_member(s, m, o) \
	_Static_assert(offsetof(struct s, m) == (o), "check_member " #m)

#define debug(...)		do { } while (0)

#define CFG_SYS_SDRAM_BASE	0x40000000UL

void *memcpy(void *dst, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
void udelay(unsigned long us);
void mctl_await_completion(u32 *reg, u32 mask, u32 val);
__attribute__((noreturn)) void stub_panic(void);
void stage(u32 code);
u64 stub_deadline(unsigned long timeout_us);
bool stub_expired(u64 deadline, unsigned long reg);
#define panic(...)		stub_panic()

/* Set by the stub: the DRAM driver runs on the resume path. */
extern bool sunxi_dram_resume;
#endif /* __ASSEMBLY__ */

#endif /* STUB_COMPAT_H */
