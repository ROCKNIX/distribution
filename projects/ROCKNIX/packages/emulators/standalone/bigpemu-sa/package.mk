# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bigpemu-sa"
PKG_VERSION="v119"
PKG_ARCH="aarch64"
PKG_LICENSE="Proprietary"
PKG_SITE="https://www.richwhitehouse.com/jaguar/"
PKG_URL="${PKG_SITE}/builds/BigPEmu_LinuxARM64_${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="BigPEmu - The World's Prefurred Large Pussycat Emulator."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/bigpemu

  cp -rf ${PKG_BUILD}/* ${INSTALL}/usr/share/bigpemu/

  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/bigpemu/userdata
  cp -rf ${PKG_DIR}/config/BigPEmuConfig.bigpcfg ${INSTALL}/usr/config/bigpemu/userdata/
}
