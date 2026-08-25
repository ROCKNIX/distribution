# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-pce-lr"
PKG_VERSION="ae99235c2139c176c1a8d0fde2957bf701d3cab0"
PKG_SHA256="2af1581ddf1a23e80fee1238707b90f605dab2e2597041069b9600ea28f83f51"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-pce-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Standalone port of Mednafen PCE to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_pce_libretro.so ${INSTALL}/usr/lib/libretro/beetle_pce_libretro.so
}
