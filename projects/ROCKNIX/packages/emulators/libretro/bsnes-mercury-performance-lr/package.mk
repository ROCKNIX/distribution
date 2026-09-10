# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bsnes-mercury-performance-lr"
PKG_VERSION="ea22363fb0c1ebe92e7a70cdf55e9bb43f9207be"
PKG_SHA256="5114fbfae7cc0e1c6479589ae43cd546acff9449cdd6849c7fab0b14c1c53214"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/bsnes-mercury"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="BSNES Super Nintendo Libretro Core"

PKG_MAKE_OPTS_TARGET="platform=unix PROFILE=performance"

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a bsnes_mercury_performance_libretro.so ${INSTALL}/usr/lib/libretro
}

