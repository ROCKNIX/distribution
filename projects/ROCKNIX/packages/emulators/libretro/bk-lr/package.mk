# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bk-lr"
PKG_VERSION="f95d929c8eca6c85075cd5c56a08aac9c58f3802"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/bk-emulator"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Linux/SDL emulator for Soviet (russian) Electronica BK serie"
PKG_TOOLCHAIN="make"

pre_make_target() {
#rm -r ${PKG_BUILD}/Makefile
  mv ${PKG_BUILD}/Makefile.libretro ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -r ${PKG_BUILD}/bk_libretro.so ${INSTALL}/usr/lib/libretro/
}
