# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-pcfx-lr"
PKG_VERSION="c1650bad5fbdcc3c3ccd45e29e3983e1ccf16cff"
PKG_SHA256="479b00626f98bf94b60b1041cbfe622b7eb80af280e642fa73ae1a5dfab018d1"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-pcfx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="libretro implementation of Mednafen PC-FX."

if [ "${ARCH}" == "i386" -o "${ARCH}" == "x86_64" ]; then
  PKG_MAKE_OPTS_TARGET="platform=unix"
else
  PKG_MAKE_OPTS_TARGET="platform=armv"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_pcfx_libretro.so ${INSTALL}/usr/lib/libretro/beetle_pcfx_libretro.so
}
