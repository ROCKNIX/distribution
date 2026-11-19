# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bigpemu-sa"
PKG_VERSION="v119"
PKG_SHA256="9128830fb1a10f6bae0ff40c780d2555a742803d63ce99ef78aef7fed3547d51"
PKG_LICENSE="proprietary"
PKG_SITE="https://www.richwhitehouse.com/jaguar"
PKG_URL="${PKG_SITE}/builds/BigPEmu_LinuxARM64_${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="BigPEmu - The World's Prefurred Large Pussycat Emulator."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/bigpemu
    cp -a ${PKG_BUILD}/* ${INSTALL}/usr/share/bigpemu

  mkdir -p ${INSTALL}/usr/config/bigpemu/userdata
    cp -a ${PKG_DIR}/config/BigPEmuConfig.bigpcfg ${INSTALL}/usr/config/bigpemu/userdata
    if [ -d "${PKG_DIR}/config/${DEVICE}" ]; then
      cp -a ${PKG_DIR}/config/${DEVICE}/BigPEmuConfig.bigpcfg ${INSTALL}/usr/config/bigpemu/userdata
    fi
}
