# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-lr"
PKG_VERSION="7a3c11ff970cd36ca806961fae6db94b30dd5401"
PKG_LICENSE="GPL"
PKG_SITE="https://git.libretro.com/libretro/melonDS"
PKG_URL="https://git.libretro.com/libretro/melonDS/-/archive/${PKG_VERSION}/melonDS-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MelonDS - Nintendo DS emulator for libretro"
PKG_TOOLCHAIN="make"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_make_target() {
  cd ${PKG_BUILD}
  if [ -e "CMakeLists.txt" ]; then
    rm CMakeLists.txt
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp melonds_libretro.so ${INSTALL}/usr/lib/libretro
}
