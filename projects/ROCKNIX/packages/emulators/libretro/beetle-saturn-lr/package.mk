# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-saturn-lr"
PKG_VERSION="ed549bdac0e1a830bb794fa720e45c225a45355c"
PKG_SHA256="cce418de1ed227c44d2127cd2f726d0d51d80afed7ce31a330a3759f096c4ada"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-saturn-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Beetle Saturn libretro, a fork from mednafen"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${ARCH}" == "i386" -o "${ARCH}" == "x86_64" ]; then
  PKG_MAKE_OPTS_TARGET="platform=unix"
else
  PKG_MAKE_OPTS_TARGET="platform=armv"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_saturn_libretro.so ${INSTALL}/usr/lib/libretro/beetle_saturn_libretro.so
}
