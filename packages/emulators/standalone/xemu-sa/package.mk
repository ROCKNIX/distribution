# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="xemu-sa"
PKG_VERSION="v0.7.127"
PKG_ARCH="x86_64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/xemu-project/xemu"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/xemu-${PKG_VERSION}-x86_64.AppImage"
PKG_DEPENDS_TARGET="toolchain libthai"
PKG_LONGDESC="Xbox Emulator appimage"
PKG_TOOLCHAIN="manual"
PKG_HDD_IMAGE="https://github.com/xqemu/xqemu-hdd-image/releases/download/v1.0/xbox_hdd.qcow2.zip"

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/start_xemu.sh ${INSTALL}/usr/bin
  sed -e "s/@APPIMAGE@/${PKG_NAME}/g" -i ${INSTALL}/usr/bin/start_xemu.sh
  chmod 755 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config
  cp -rf ${PKG_DIR}/config/xemu ${INSTALL}/usr/config

  #Download HDD IMAGE
  curl -Lo ${INSTALL}/usr/config/xemu/hdd.zip ${PKG_HDD_IMAGE}
}
