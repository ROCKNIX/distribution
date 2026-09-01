# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gambatte-lr"
PKG_VERSION="d9d6cd06382d1ced30de34d56d3609452323dab1"
PKG_SHA256="bd39cd38662135d17e221a7fd34baf2908a40065ade16edf2e8d1168b21b921e"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/gambatte-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of libgambatte"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a gambatte_libretro.so ${INSTALL}/usr/lib/libretro
}
