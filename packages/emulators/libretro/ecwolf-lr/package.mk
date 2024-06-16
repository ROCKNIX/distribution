# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ecwolf-lr"
PKG_VERSION="71ec64cf98ba0a2a94e2fede560f1b435761b36d"
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

pre_configure_target() {
	CXXFLAGS="${CXXFLAGS} -Wno-error=int-conversion"
}

pre_make_target() {
  cd ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp src/libretro/ecwolf_libretro.so ${INSTALL}/usr/lib/libretro/
}
