# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="beetle-saturn-lr"
PKG_VERSION="7a8f808a1d447fcb8fa9547d9f163eb3600d3086"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/beetle-saturn-libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Beetle Saturn libretro, a fork from mednafen"
PKG_TOOLCHAIN="make"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

make_target() {
  if [ "${ARCH}" == "i386" -o "${ARCH}" == "x86_64" ]; then
    make platform=unix CC=${CC} CXX=${CXX} AR=${AR}
  else
    make platform=armv CC=${CC} CXX=${CXX} AR=${AR}
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp mednafen_saturn_libretro.so ${INSTALL}/usr/lib/libretro/beetle_saturn_libretro.so
}
