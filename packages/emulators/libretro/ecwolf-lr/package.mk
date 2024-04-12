# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ecwolf-lr"
PKG_VERSION="18eca17c2d634b154824e0782c6cbbe0a2c9ea76"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/ecwolf"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer SDL2_net libjpeg-turbo bzip2"
PKG_LONGDESC="ECWolf is a port of the Wolfenstein 3D engine based of Wolf4SDL."
PKG_TOOLCHAIN="make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_MAKE_OPTS_TARGET="-C src/libretro"

pre_make_target() {
  cd ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp src/libretro/ecwolf_libretro.so ${INSTALL}/usr/lib/libretro/
}
