# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="eden-sa"
PKG_VERSION="f0a4ac7359b6de6d6f1926c795831de01d4119d5" # v0.2.0-rc2
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain SDL2 boost libevdev libdrm ffmpeg zlib libpng lzo libusb zstd ecm openal-soft pulseaudio alsa-lib llvm qt6 libfmt libva libX11"
PKG_LONGDESC="Eden is a high-performance and easy-to-use emulator, tailored for enthusiasts and developers alike."
PKG_SITE="https://git.eden-emu.dev/eden-emu/eden"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_TOOLCHAIN="cmake"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
}

PKG_CMAKE_OPTS_TARGET+=" -DYUZU_BUILD_PRESET=generic \
    -DENABLE_QT_TRANSLATION=ON \
    -DUSE_DISCORD_PRESENCE=OFF \
    -DYUZU_USE_BUNDLED_SIRIT=ON \
    -DYUZU_USE_BUNDLED_QT=OFF \
    -DYUZU_USE_BUNDLED_SDL2=OFF \
    -DYUZU_USE_EXTERNAL_SDL2=ON \
    -DYUZU_TESTS=OFF \
    -DYUZU_USE_QT_MULTIMEDIA=OFF \
    -DYUZU_USE_QT_WEB_ENGINE=OFF \
    -DYUZU_ROOM=ON \
    -DYUZU_ROOM_STANDALONE=OFF \
    -DYUZU_CMD=OFF \
    -DVulkanHeaders_FORCE_BUNDLED=ON \
    -DENABLE_LTO=ON \
    -DCMAKE_BUILD_TYPE=Release"


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/eden  ${INSTALL}/usr/bin/
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config/eden
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/eden/
}
