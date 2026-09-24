# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ep128emu-core-lr"
PKG_VERSION="e370ca7273f5eb3a7042e61acfea8bcb197c8c97" # tag core_v1.2.13
PKG_SHA256="f1b2b0b671dabc80eb77797bb653ce3afd59748d1b33f78d854683b534ca4d68"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/ep128emu-core"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ep128emu, an Enterprise 64/128, Videoton TVC, Amstrad CPC and ZX Spectrum emulator"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ep128emu_core_libretro.so ${INSTALL}/usr/lib/libretro
}
