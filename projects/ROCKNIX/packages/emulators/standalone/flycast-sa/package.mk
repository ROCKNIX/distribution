# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="flycast-sa"
PKG_VERSION="5aa091fde632fb332c8d8c34e280d62dc951954c" #v2.7
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/flyinghead/flycast"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain alsa SDL2 libzip curl miniupnpc lua54 libao"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast, Naomi and Atomiswave emulator"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_OPENGL=ON -DUSE_GLES=OFF"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_GLES=ON"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=ON"
  GRENDERER="4"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN=OFF"
  GRENDERER="0"
fi

PKG_CMAKE_OPTS_TARGET+=" -DUSE_OPENMP=ON"

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/CMakeLists.txt
}

pre_configure_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-error=array-bounds"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/flycast ${INSTALL}/usr/bin/flycast
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/flycast
    cp -aL ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/flycast
    cp -a ${PKG_DIR}/config/flycast.gptk ${INSTALL}/usr/config/flycast
    cp -a ${PKG_DIR}/config/SDL_Keyboard.cfg ${INSTALL}/usr/config/flycast/mappings
}

post_install() {
  sed -e "s/@GRENDERER@/${GRENDERER}/g" -i ${INSTALL}/usr/bin/start_flycast.sh
}
