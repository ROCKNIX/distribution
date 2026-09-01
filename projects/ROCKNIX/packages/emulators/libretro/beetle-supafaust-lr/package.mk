# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-supafaust-lr"
PKG_VERSION="642d1d1b6684aa7e306a02a89885f3f5456a5157"
PKG_SHA256="257b3e3d5c6a1db16b9fe8d3b6fff956732df7d8c8b0a4865ca6d6534fc9145c"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/supafaust"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Super Nintendo (Super Famicom) emulator"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/mednafen_supafaust_libretro.so ${INSTALL}/usr/lib/libretro/beetle_supafaust_libretro.so

  mkdir -p ${INSTALL}/usr/config/retroarch
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch
}
