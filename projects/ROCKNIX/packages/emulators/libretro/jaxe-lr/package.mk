# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="jaxe-lr"
PKG_VERSION="c767afd785e01a15bcd575a2d93b737add82b675"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/kurtjd/jaxe"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fully-featured, cross platform XO-CHIP/S-CHIP/CHIP-8 emulator written in C and SDL"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C .. -f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/jaxe_libretro.so ${INSTALL}/usr/lib/libretro
}
