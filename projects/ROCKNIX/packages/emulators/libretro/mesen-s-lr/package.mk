# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mesen-s-lr"
PKG_VERSION="9e4fdeb9b336470bc96beb8765b2e79c86a2da1e"
PKG_SHA256="2e17d972a1b5e678cb4780df8ab53feac13c0c0b908e602ec0cf10619d8bf1a0"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/Mesen-S"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Mesen-S is a cross-platform SNES emulator built in C++"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C Libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/Libretro/mesen-s_libretro.so ${INSTALL}/usr/lib/libretro
}
