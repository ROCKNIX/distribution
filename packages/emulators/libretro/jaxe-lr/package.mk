# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="jaxe-lr"
PKG_VERSION="22115d58de5f80cfafbbeece19d723f4892ed75c"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/kurtjd/jaxe"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fully-featured, cross platform XO-CHIP/S-CHIP/CHIP-8 emulator written in C and SDL"
PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}
  make -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/jaxe_libretro.so ${INSTALL}/usr/lib/libretro/
}
