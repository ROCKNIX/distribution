# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="boom3-lr"
PKG_VERSION="0bea79abf5ec8262dfe9af73cb8c54ea6e2aeb98"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/boom3"
PKG_URL="https://github.com/libretro/boom3/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Doom3 - dhewm3 port to libretro."
PKG_TOOLCHAIN="make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

make_target() {
  make -C neo BASE=1
  make -C neo D3XP=1
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/neo/boom3_libretro.so ${INSTALL}/usr/lib/libretro/
  cp -v ${PKG_BUILD}/neo/boom3_xp_libretro.so ${INSTALL}/usr/lib/libretro/
}
