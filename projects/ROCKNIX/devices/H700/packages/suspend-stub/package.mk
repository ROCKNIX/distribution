# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="suspend-stub"
PKG_VERSION="1.0"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/kailashrs/H700_rocknix_enhancement"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="SRAM resume stub for H700 system suspend: puts DRAM in self-refresh and brings it back."
PKG_TOOLCHAIN="manual"

# The DRAM sources are U-Boot's own, taken from the bootloader package's
# unpacked tree. Source only: a target dependency here would close the loop
# u-boot -> atf -> suspend-stub -> u-boot.
PKG_UBOOT="u-boot-DDR4"
PKG_DEPENDS_UNPACK="${PKG_UBOOT}"
PKG_NEED_UNPACK="$(get_pkg_directory ${PKG_UBOOT})"

# atf builds one bl31 that both bootloader variants embed, so the stub can be
# built for one memory type only, and LPDDR4 is the one that has been tested.
# TF-A compares the live DRAM type and clock against these parameters before
# it offers system suspend, so a DDR3 device loses suspend instead of resuming
# with the wrong settings.
PKG_UBOOT_DEFCONFIG="anbernic_rg35xx_h700_lpddr4_defconfig"

configure_target() {
  UBOOT_DIR="$(get_build_dir ${PKG_UBOOT})"
  DEFCONFIG="${UBOOT_DIR}/configs/${PKG_UBOOT_DEFCONFIG}"
  [ -r "${DEFCONFIG}" ] || die "suspend-stub: ${PKG_UBOOT_DEFCONFIG} not found in ${PKG_UBOOT}"
  grep -q "^CONFIG_SUNXI_DRAM_H616_LPDDR4=y" "${DEFCONFIG}" ||
    die "suspend-stub: ${PKG_UBOOT_DEFCONFIG} is no longer LPDDR4; the stub's DRAM code must match"

  # DRAM sources, unmodified from U-Boot apart from the resume patch.
  mkdir -p ${PKG_BUILD}/src/dram
  cp ${UBOOT_DIR}/arch/arm/mach-sunxi/dram_sun50i_h616.c \
     ${UBOOT_DIR}/arch/arm/mach-sunxi/dram_dw_helpers.c ${PKG_BUILD}/src/dram/
  cp ${UBOOT_DIR}/arch/arm/mach-sunxi/dram_timings/h616_lpddr4_2133.c \
     ${PKG_BUILD}/src/dram/dram_timing.c
  # kept out of patches/ so the framework does not try to apply it at unpack
  patch -d ${PKG_BUILD}/src/dram -p1 <${PKG_BUILD}/dram-resume.patch

  # DRAM parameters straight out of that defconfig, so the stub resumes with
  # the settings the SPL booted with.
  mkdir -p ${PKG_BUILD}/boards
  grep -E '^CONFIG_(DRAM_|SUNXI_DRAM_H616_)' ${DEFCONFIG} |
    sed -e 's/=y$/ 1/' -e 's/=/ /' -e 's/^/#define /' >${PKG_BUILD}/boards/board.h
  grep -q "^#define CONFIG_DRAM_CLK " ${PKG_BUILD}/boards/board.h ||
    die "suspend-stub: no CONFIG_DRAM_* found in ${DEFCONFIG}"
  # Symbols the driver reads but the defconfig leaves at their Kconfig
  # default, taken from U-Boot's own Kconfig rather than assumed here.
  awk '/^config DRAM_[A-Z0-9_]+$/ { name = $2; next }
       /^\tdefault / && name != "" && $2 ~ /^0x?[0-9a-fA-F]*$/ {
         print "#define CONFIG_" name " " $2; name = ""; next }
       /^config |^endmenu|^menu/ { name = "" }' \
    ${UBOOT_DIR}/arch/arm/mach-sunxi/Kconfig |
    while read -r line; do
      sym=$(echo "${line}" | cut -d' ' -f2)
      grep -q "^#define ${sym} " ${PKG_BUILD}/boards/board.h || echo "${line}"
    done >>${PKG_BUILD}/boards/board.h
  # SUNXI_DRAM_TYPE_LPDDR4, and the uMCTL2 MSTR device-type bit for it.
  echo "#define STUB_DRAM_TYPE 8" >>${PKG_BUILD}/boards/board.h
  echo "#define STUB_MSTR_DEVICETYPE (1 << 5)" >>${PKG_BUILD}/boards/board.h
}

make_target() {
  UBOOT_DIR="$(get_build_dir ${PKG_UBOOT})"
  CFLAGS="-Iinclude -Icompat -I${UBOOT_DIR}/arch/arm/include/asm/arch-sunxi \
    -include compat/stub_compat.h -include boards/board.h -DSTUB_DRAM_KEEP_PHY=0 \
    -Os -std=gnu11 -march=armv8-a -mgeneral-regs-only -mstrict-align -mcmodel=small \
    -ffreestanding -fno-builtin -fno-pic -fno-pie -fno-stack-protector -fno-common \
    -ffunction-sections -fdata-sections -Wall -Wno-unused-function"

  ${TARGET_KERNEL_PREFIX}gcc -march=armv8-a -D__ASSEMBLY__ -c src/start.S -o start.o
  for c in src/main.c src/lib.c src/clock.c src/dram_sr.c \
           src/dram/dram_sun50i_h616.c src/dram/dram_dw_helpers.c src/dram/dram_timing.c; do
    ${TARGET_KERNEL_PREFIX}gcc ${CFLAGS} -c ${c} -o $(basename ${c} .c).o
  done
  ${TARGET_KERNEL_PREFIX}gcc -march=armv8-a -mgeneral-regs-only -ffreestanding -nostdlib \
    -static -no-pie -Wl,--gc-sections -Wl,-T,stub.lds -Wl,--build-id=none \
    start.o main.o lib.o clock.o dram_sr.o dram_sun50i_h616.o dram_dw_helpers.o dram_timing.o \
    -o suspend_stub.elf
  ${TARGET_KERNEL_PREFIX}objcopy -O binary suspend_stub.elf suspend_stub.bin
}

makeinstall_target() {
  : # atf embeds suspend_stub.bin in bl31; nothing from this package is installed
}
