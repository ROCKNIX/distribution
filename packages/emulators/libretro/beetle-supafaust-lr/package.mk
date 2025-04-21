# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-supafaust-lr"
PKG_VERSION="e25f66765938d33f9ad5850e8d6cd597e55b7299"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/supafaust"
PKG_URL="https://github.com/libretro/supafaust/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Super Nintendo (Super Famicom) emulator"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/mednafen_supafaust_libretro.so ${INSTALL}/usr/lib/libretro/beetle_supafaust_libretro.so

  mkdir -p ${INSTALL}/usr/config/retroarch
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch
}
