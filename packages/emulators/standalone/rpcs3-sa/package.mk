# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rpcs3-sa"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/RPCS3/rpcs3-binaries-linux"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 qt6 mesa libcom-err"
PKG_LONGDESC="PS3 Emulator appimage"
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    PKG_VERSION="68b7e5971d8e279d7d385b96b5aa2feebd220506"
    PKG_REL_VERSION="v0.0.34-17173-68b7e597"
    PKG_URL="${PKG_SITE}/releases/download/build-${PKG_VERSION}/rpcs3-${PKG_REL_VERSION}_linux64.AppImage"
  ;;
  aarch64)
    PKG_VERSION="68b7e5971d8e279d7d385b96b5aa2feebd220506"
    PKG_REL_VERSION="v0.0.34-17173-68b7e597"
    PKG_URL="${PKG_SITE}-arm64/releases/download/build-${PKG_VERSION}/rpcs3-${PKG_REL_VERSION}_linux_aarch64.AppImage"
  ;;
esac

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/start_rpcs3.sh ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config/rpcs3
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/rpcs3/
}
