# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="skyemu-sa"
PKG_VERSION="36771a16bfde7eb5c1c0315877b5e465e6f38858"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/skylersaleh/SkyEmu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="SkyEmu is a low level GameBoy, GameBoy Color, Game Boy Advance, and DS emulator."
PKG_DEPENDS_TARGET="toolchain SDL2 openssl curl"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DENABLE_RETRO_ACHIEVEMENTS=ON \
                           -DUSE_SYSTEM_CURL=ON \
                           -DUSE_SYSTEM_OPENSSL=ON \
                           -DUSE_SYSTEM_SDL2=ON"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/bin/SkyEmu ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/SkyEmu
  cp -r ${PKG_DIR}/config/* ${INSTALL}/usr/config/SkyEmu
}
