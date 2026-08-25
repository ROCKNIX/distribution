# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mgba-lr"
PKG_VERSION="e31759b24e7a4e3899285ff720d7b573ac328ae7"
PKG_SHA256="396d749cce8fe3358b29cbb1db479b1816a151bd688ee45b1d241503cbc40243"
PKG_LICENSE="MPL-2.0"
PKG_SITE="https://github.com/libretro/mgba"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="mGBA Game Boy Advance Emulator"

PKG_CMAKE_OPTS_TARGET="-DLIBMGBA_ONLY=ON -DBUILD_LIBRETRO=ON"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mgba_libretro.so ${INSTALL}/usr/lib/libretro
}
