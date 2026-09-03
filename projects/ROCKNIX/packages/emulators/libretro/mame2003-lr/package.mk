# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mame2003-lr"
PKG_VERSION="259339e92d5f63e4b293ce0d42a069f9e8ba2a6a"
PKG_SHA256="84dd49cb72af2625969aaa9df3a359ecdf04549cc5d7e589286ab63273caf5de"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame2003-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mame2003_libretro.so ${INSTALL}/usr/lib/libretro
}
