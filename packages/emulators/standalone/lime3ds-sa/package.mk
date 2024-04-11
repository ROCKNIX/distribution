# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lime3ds-sa"
PKG_VERSION="ff46656809278d797ff8d79514e0a1c6e57bf9be"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Lime3DS/Lime3DS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ffmpeg mesa SDL2 boost zlib libusb boost zstd control-gen"
PKG_LONGDESC="Lime3DS - Nintendo 3DS emulator"
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

PKG_CMAKE_OPTS_TARGET+="-DENABLE_QT=OFF \
                        -DENABLE_QT_TRANSLATION=OFF \
                        -DENABLE_SDL2=ON \
                        -DCITRA_WARNINGS_AS_ERRORS=OFF \
                        -DUSE_DISCORD_PRESENCE=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/.${TARGET_NAME}/bin/MinSizeRel/lime ${INSTALL}/usr/bin/lime3ds
    cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/lime3ds
    cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/lime3ds
}
