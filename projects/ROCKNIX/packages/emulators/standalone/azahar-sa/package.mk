# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="azahar-sa"
PKG_VERSION="54f35a72f9961f2aa6e18f0b17d4c51c157c819a" # tag 2124.3
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ffmpeg mesa SDL2 boost zlib libusb boost zstd control-gen spirv-tools qt6"
PKG_LONGDESC="Azahar - Nintendo 3DS emulator"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS="common"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"

  if [ "${PREFER_GLES}" = "yes" ]; then
    PKG_PATCH_DIRS+=" prefer_gles"
  fi
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

TARGET_CXXFLAGS+=-fpch-preprocess

PKG_CMAKE_OPTS_TARGET+="-DENABLE_OPENGL=ON \
                        -DENABLE_QT_TRANSLATION=OFF \
                        -DENABLE_QT=ON \
                        -DENABLE_ROOM=OFF \
                        -DENABLE_SDL2_FRONTEND=OFF \
                        -DENABLE_SDL2=ON \
                        -DENABLE_TESTS=OFF \
                        -DENABLE_VULKAN=ON \
                        -DUSE_DISCORD_PRESENCE=OFF \
                        -DUSE_SYSTEM_SDL2=ON"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/Release/azahar ${INSTALL}/usr/bin/azahar
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/azahar
  cp -rf ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/azahar
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/azahar
}
