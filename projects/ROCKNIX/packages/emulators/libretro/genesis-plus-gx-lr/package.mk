# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="genesis-plus-gx-lr"
PKG_VERSION="b7e79b3641eb2e322c5ba29903352e115887e83c"
PKG_SHA256="5e240e3c9e2cfae0dada87650005c289ed80e31c77c524945fc2c521f787455c"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/Genesis-Plus-GX"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="An enhanced port of Genesis Plus for Gamecube/Wii"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a genesis_plus_gx_libretro.so ${INSTALL}/usr/lib/libretro/genesis_plus_gx_libretro.so
}
