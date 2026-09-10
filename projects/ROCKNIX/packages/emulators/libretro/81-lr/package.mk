# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="81-lr"
PKG_VERSION="fa7094910d040baa5fd8b11dbf6a1a618330ecd9"
PKG_SHA256="fe8645529ce2140d29d2cad65dc2144bb3a41d858fd23345f85e412081d26aad"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/81-libretro"
PKG_URL="https://github.com/libretro/81-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A port of the EightyOne ZX81 Emulator to libretro"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a 81_libretro.so ${INSTALL}/usr/lib/libretro
}
