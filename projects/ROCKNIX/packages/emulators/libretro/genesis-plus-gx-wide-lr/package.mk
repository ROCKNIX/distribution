# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="genesis-plus-gx-wide-lr"
PKG_VERSION="b7ad005431f5f0b55e559f6d598d1ed2479bf13b"
PKG_SHA256="ce5bd58df616da98db6d1fd1761ebcb40a7cacb5d30afaaa8ba65f0e126e2950"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/Genesis-Plus-GX-Wide"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="An enhanced port of Genesis Plus for Gamecube/Wii"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a genesis_plus_gx_wide_libretro.so ${INSTALL}/usr/lib/libretro/genesis_plus_gx_wide_libretro.so
}
