# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="swanstation-lr"
PKG_VERSION="7f69c199ed88d5723f71dd3a6e9c1b7a45b535a6"
PKG_SHA256="d3a9e60a8b338f3edcfd8caeff54bbecc797668f0cda9e85f703255f69c5a821"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/swanstation"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host"
PKG_LONGDESC="SwanStation - PlayStation 1, aka. PSX Emulator"
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-lto"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

PKG_CMAKE_OPTS_TARGET="-DBUILD_LIBRETRO_CORE=ON"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a swanstation_libretro.so ${INSTALL}/usr/lib/libretro
}
