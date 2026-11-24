# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mame2003-plus-lr"
PKG_VERSION="e455f1783a9a3a3cd00d334e39ae35aaf33b1128"
PKG_SHA256="438739be3b90ff77389463bec4d0772029d7a5a760ae72579e9049209449ff5a"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame2003-plus-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mame2003_plus_libretro.so ${INSTALL}/usr/lib/libretro
}
