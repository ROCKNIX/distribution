# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gw-lr"
PKG_VERSION="91d599b951e7bfe7e040347f58667cba20074adc"
PKG_SHA256="88f47e3fe2ce7a5cdf42a087386a6cff5379dd2fe7901761c80a9f8d0d2185ad"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/libretro/gw-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A libretro core for Game & Watch simulators "

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a gw_libretro.so ${INSTALL}/usr/lib/libretro
}
