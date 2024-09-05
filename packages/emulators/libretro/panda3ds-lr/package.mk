# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="panda3ds-lr"
PKG_VERSION="f1b7830952e98299a62d325333cbe83b7bf81e83"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/wheremyfoodat/Panda3DS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Panda3DS is an HLE, red-panda-themed Nintendo 3DS emulator"
PKG_TOOLCHAIN="cmake"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
  PKG_CMAKE_OPTS_TARGET+="      -DOPENGL_PROFILE=OpenGL"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_PATCH_DIRS+=" gles"
  PKG_CMAKE_OPTS_TARGET+="      -DOPENGL_PROFILE=OpenGLES"
fi

PKG_CMAKE_OPTS_TARGET+="	-DBUILD_LIBRETRO_CORE=ON \
				-DENABLE_USER_BUILD=ON \
				-DENABLE_DISCORD_RPC=OFF \
				-DENABLE_LUAJIT=OFF \
				-DSDL_VIDEO=OFF \
				-DSDL_AUDIO=OFF \
				-DENABLE_VULKAN=OFF \
				-DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/.${TARGET_NAME}/panda3ds_libretro.so ${INSTALL}/usr/lib/libretro/panda3ds_libretro.so
}
