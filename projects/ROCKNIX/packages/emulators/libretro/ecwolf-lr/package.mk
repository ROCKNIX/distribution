# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ecwolf-lr"
PKG_VERSION="0cccd9a85d7ffa33fb695691a8a5db246606518c"
PKG_SHA256="eda0719e0d93abea3667e658764cbab21c9f370c5f6e1166c31f39fe00c3e246"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/ecwolf"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer SDL2_net libjpeg-turbo bzip2"
PKG_LONGDESC="ECWolf is a port of the Wolfenstein 3D engine based of Wolf4SDL."
PKG_TOOLCHAIN="make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_MAKE_OPTS_TARGET="-C src/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a src/libretro/ecwolf_libretro.so ${INSTALL}/usr/lib/libretro
}
