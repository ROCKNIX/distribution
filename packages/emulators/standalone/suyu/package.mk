# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="suyu"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain SDL2 boost libevdev libdrm ffmpeg zlib libpng lzo libusb zstd ecm openal-soft pulseaudio alsa-lib llvm qt6 libfmt vulkan-headers"
PKG_LONGDESC="SuYu is a Switch emulator, allowing you to play games for this platforms on PC with improvements. "
PKG_TOOLCHAIN="cmake"
PKG_SITE="https://git.suyu.dev/suyu/suyu"
PKG_URL="${PKG_SITE}.git"
PKG_VERSION="ee365bad9501c73ff49936e72ec91cd9c3ce5c24"
PKG_CMAKE_OPTS_TARGET+=" -DSUYU_USE_BUNDLED_QT=OFF \
											 -DENABLE_SDL=ON -DENABLE_QT6=ON \
											 -DSUYU_USE_EXTERNAL_SDL2=ON \
											 -DSUYU_USE_BUNDLED_FFMPEG=OFF \
											 -DSUYU_TESTS=OFF "

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/.${TARGET_NAME}/bin/suyu  ${INSTALL}/usr/bin/
    cp ${PKG_BUILD}/.${TARGET_NAME}/bin/suyu-cmd  ${INSTALL}/usr/bin/
    cp ${PKG_BUILD}/.${TARGET_NAME}/bin/suyu-room  ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/config/suyu
    cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/suyu
}
