# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="panda3ds-lr"
PKG_VERSION="5aaa1d26565c834a6f1999026260e559f54aacf1"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/wheremyfoodat/Panda3DS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Panda3DS is an HLE, red-panda-themed Nintendo 3DS emulator"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
  PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_PROFILE=OpenGL"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_PATCH_DIRS+=" gles"
  PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_PROFILE=OpenGLES"
fi

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_LIBRETRO_CORE=ON \
                         -DENABLE_USER_BUILD=ON \
                         -DENABLE_DISCORD_RPC=OFF \
                         -DENABLE_LUAJIT=OFF \
                         -DSDL_VIDEO=OFF \
                         -DSDL_AUDIO=OFF \
                         -DENABLE_VULKAN=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a panda3ds_libretro.so ${INSTALL}/usr/lib/libretro/panda3ds_libretro.so
}
