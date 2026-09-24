# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gp32emu-lr"
PKG_VERSION="25df8b8a2501e730d77932e007a295fb24e619f1" # tag 1.0
PKG_SHA256="f1c6c178472fe75f9638c18bc4b2be9cd4805b90c521f1b03bea49d38967102d"
PKG_LICENSE="BSD-3-Clause AND MIT"
PKG_SITE="https://github.com/gameblabla/gp32emu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="GP32emu, a GamePark GP32 emulator"
PKG_TOOLCHAIN="make"

make_target() {
  make -C ${PKG_BUILD} -f Makefile.libretro CFLAGS="${CFLAGS} -std=c11 -O3 -fPIC"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/gp32emu_libretro.so ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/gp32emu_libretro.info ${INSTALL}/usr/lib/libretro
}
