# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mame2003-plus-lr"
PKG_VERSION="8202aeaacab1091cb4cb8b7614b60d8de8b3cdc8" # DsNo (260817)
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/aleksei74/mame2003-plus-dsno-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"

PKG_TOOLCHAIN="make"

make_target() {
  make ARCH="" CC="${CC}" NATIVE_CC="${CC}" LD="${CC}" GIT_VERSION=" ${PKG_VERSION:0:10}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mame2003_plus_libretro.so ${INSTALL}/usr/lib/libretro
}
