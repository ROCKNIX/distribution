# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aethersx2-sa"
PKG_VERSION="1.0"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/ROCKNIX/packages"
PKG_URL="${PKG_SITE}/raw/refs/heads/main/aethersx2.tar.gz"
PKG_DEPENDS_TARGET="toolchain qt5 libgpg-error fuse2"
PKG_LONGDESC="Arm PS2 Emulator appimage"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/aethersx2-sa

  cp -rf ${PKG_BUILD}/usr/share/* ${INSTALL}/usr/share/aethersx2-sa/

  cp -rf ${PKG_DIR}/scripts/start_aethersx2.sh ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config
  cp -rf ${PKG_DIR}/config/${DEVICE}/aethersx2 ${INSTALL}/usr/config
}
