# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="aethersx2-sa"
PKG_VERSION="v1.5-3606"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/ROCKNIX/packages"
PKG_URL="${PKG_SITE}/raw/main/aethersx2-sa-${PKG_VERSION}.AppImage"
PKG_DEPENDS_TARGET="toolchain qt5 libgpg-error fuse2"
PKG_LONGDESC="Arm PS2 Emulator appimage"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/start_aethersx2.sh ${INSTALL}/usr/bin
  sed -e "s/@APPIMAGE@/${PKG_NAME}/g" -i ${INSTALL}/usr/bin/start_aethersx2.sh
  chmod 755 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config
  cp -rf ${PKG_DIR}/config/${DEVICE}/aethersx2 ${INSTALL}/usr/config
}
