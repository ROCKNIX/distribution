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

# The DRAM sources are U-Boot's own, compiled from the bootloader package's
# tree so the stub resumes with the parameters the SPL booted with.
PKG_UBOOT="u-boot-${SUBDEVICES%% *}"
PKG_DEPENDS_TARGET+=" ${PKG_UBOOT}"
PKG_DEPENDS_UNPACK="${PKG_UBOOT}"
PKG_NEED_UNPACK="$(get_pkg_directory ${PKG_UBOOT})"

configure_target() {
  UBOOT_DIR="$(get_build_dir ${PKG_UBOOT})"
  DEFCONFIG="${UBOOT_DIR}/configs/$(sed -n 's/^\s*PKG_UBOOT_CONFIG="\(.*\)"/\1/p' $(get_pkg_directory ${PKG_UBOOT})/package.mk)"

  # DRAM sources, unmodified from U-Boot apart from the resume patch.
  mkdir -p ${PKG_BUILD}/src/dram
  cp ${UBOOT_DIR}/arch/arm/mach-sunxi/dram_sun50i_h616.c \
     ${UBOOT_DIR}/arch/arm/mach-sunxi/dram_dw_helpers.c ${PKG_BUILD}/src/dram/
  cp ${UBOOT_DIR}/arch/arm/mach-sunxi/dram_timings/h616_lpddr4_2133.c \
     ${PKG_BUILD}/src/dram/dram_timing.c
  patch -d ${PKG_BUILD} -p1 <${PKG_DIR}/patches/0001-sunxi-dram-h616-resume-path-for-the-suspend-stub.patch

  # DRAM parameters come from the defconfig the bootloader is built with, so a
  # DDR3 device cannot be given a stub built for DDR4. TF-A checks them again
  # against the live controller before it offers system suspend at all.
  mkdir -p ${PKG_BUILD}/boards
  grep -E '^CONFIG_(DRAM_|SUNXI_DRAM_H616_)' ${DEFCONFIG} |
    sed -e 's/=y$/ 1/' -e 's/=/ /' -e 's/^/#define /' >${PKG_BUILD}/boards/board.h
  case "$(grep -oE 'CONFIG_SUNXI_DRAM_H616_[A-Z0-9]+' ${DEFCONFIG} | head -1)" in
    *LPDDR4) echo "#define STUB_DRAM_TYPE 8"; echo "#define STUB_MSTR_DEVICETYPE (1 << 5)" ;;
    *LPDDR3) echo "#define STUB_DRAM_TYPE 7"; echo "#define STUB_MSTR_DEVICETYPE (1 << 3)" ;;
    *DDR3)   echo "#define STUB_DRAM_TYPE 3"; echo "#define STUB_MSTR_DEVICETYPE (1 << 0)" ;;
    *) echo "unknown DRAM type in ${DEFCONFIG}" >&2; exit 1 ;;
  esac >>${PKG_BUILD}/boards/board.h
}

make_target() {
  UBOOT_DIR="$(get_build_dir ${PKG_UBOOT})"
  ${TARGET_KERNEL_PREFIX}gcc -Iinclude -Icompat -I${UBOOT_DIR}/arch/arm/include/asm/arch-sunxi \
    -include compat/stub_compat.h -include boards/board.h -DSTUB_DRAM_KEEP_PHY=0 \
    -Os -std=gnu11 -march=armv8-a -mgeneral-regs-only -mstrict-align -mcmodel=small \
    -ffreestanding -fno-builtin -fno-pic -fno-pie -fno-stack-protector -fno-common \
    -ffunction-sections -fdata-sections -Wall -Wno-unused-function \
    -nostdlib -static -no-pie -Wl,--gc-sections -Wl,-T,stub.lds -Wl,--build-id=none \
    src/start.S src/main.c src/lib.c src/clock.c src/dram_sr.c \
    src/dram/dram_sun50i_h616.c src/dram/dram_dw_helpers.c src/dram/dram_timing.c \
    -o suspend_stub.elf
  ${TARGET_KERNEL_PREFIX}objcopy -O binary suspend_stub.elf suspend_stub.bin
}

makeinstall_target() {
  : # consumed by atf, nothing lands in the image
}
