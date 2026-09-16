/* SPDX-License-Identifier: GPL-2.0+ */
#ifndef STUB_ASM_IO_H
#define STUB_ASM_IO_H

#define __stub_reg(a)			((volatile u32 *)(unsigned long)(a))

/* MMIO accesses must not be cached, combined, or removed by the compiler.
 * The stub uses physical, little-endian Device memory with the MMU off.
 * Match the ordering of U-Boot's ARM readl/writel accessors.
 */
#define dmb()				__asm__ volatile("dmb sy" : : : "memory")
#define readl(a) ({ u32 __v = *__stub_reg(a); dmb(); __v; })
#define writel(v, a) do { dmb(); *__stub_reg(a) = (u32)(v); } while (0)
#define writel_relaxed(v, a)		(*__stub_reg(a) = (u32)(v))
#define setbits_le32(a, s)		writel(readl(a) | (s), a)
#define clrbits_le32(a, c)		writel(readl(a) & ~(c), a)
#define clrsetbits_le32(a, c, s)	writel((readl(a) & ~(c)) | (s), a)

#endif /* STUB_ASM_IO_H */
