# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present asakous (https://github.com/asakous)

PKG_NAME="xmil-lr"
PKG_VERSION="927e2eb8c097e88f623efdf15c4372b973a6c5e5"
PKG_LICENSE="Unknown"
PKG_SITE="https://github.com/libretro/xmil-libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro port of X Millennium Sharp X1 emulator"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

make_target() {
  cd ${PKG_BUILD}
    make -C libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/libretro/x1_libretro.so ${INSTALL}/usr/lib/libretro/
}
