# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="flycast-lr"
PKG_VERSION="7adbf3caef251b153e348df3f469a0f35878339d"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/flyinghead/flycast"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain retroarch zlib libzip"
PKG_LONGDESC="Flycast is a multi-platform Sega Dreamcast, Naomi and Atomiswave emulator"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_OPENGL=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_OPENGL=OFF"
fi

if [ "${OPENGLES_SUPPORT}" = yes ] && [ "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  ### Will fail to compile if USE_OPENGL=OFF and USE_GLES=ON as both options are required.
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_OPENGL=ON -DUSE_GLES=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_GLES=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=OFF"
fi

PKG_CMAKE_OPTS_TARGET+=" -DLIBRETRO=ON \
                         -DWITH_SYSTEM_ZLIB=ON \
                         -DUSE_OPENMP=ON"

post_unpack() {
  # needed for copying repo to build
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a flycast_libretro.so ${INSTALL}/usr/lib/libretro/flycast_libretro.so

  mkdir -p ${INSTALL}/usr/config/retroarch
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch
}
