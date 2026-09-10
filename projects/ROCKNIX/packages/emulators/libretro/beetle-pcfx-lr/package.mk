# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-pcfx-lr"
PKG_VERSION="0580dee757adfdb9bf8b9c24693dde5f3d0a78a1"
PKG_SHA256="af1d5b2ecafb43e668e5ff24978772e180397d8305003c8f3c6bd960aa9bf11b"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-pcfx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
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
