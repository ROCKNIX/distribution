# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="azahar-sa"
PKG_VERSION="b42d0916ba9799297ae0e27c07d56801da1b5de5" # tag 2125.1.3
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ffmpeg mesa SDL2 boost zlib libusb zstd control-gen spirv-tools qt6"
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

PKG_CMAKE_OPTS_TARGET+="-DENABLE_OPENGL=ON \
                        -DENABLE_QT=ON \
                        -DENABLE_QT_TRANSLATION=OFF \
                        -DENABLE_ROOM=OFF \
                        -DENABLE_SDL2=ON \
                        -DENABLE_TESTS=OFF \
                        -DENABLE_VULKAN=ON \
                        -DUSE_DISCORD_PRESENCE=OFF"

pre_configure_target() {
  export CXXFLAGS+=-fpch-preprocess
  export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/Release/azahar ${INSTALL}/usr/bin/azahar
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/azahar
  cp -rf ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/azahar
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/azahar
}
