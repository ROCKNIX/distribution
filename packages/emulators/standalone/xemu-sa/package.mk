# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="xemu-sa"
PKG_VERSION="v0.7.127"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/xemu-project/xemu"
PKG_DEPENDS_TARGET="toolchain libthai gtk3 libsamplerate libpcap atk"
PKG_LONGDESC="Xbox Emulator appimage"
PKG_TOOLCHAIN="manual"
PKG_HDD_IMAGE="https://github.com/xqemu/xqemu-hdd-image/releases/download/v1.0/xbox_hdd.qcow2.zip"

case ${TARGET_ARCH} in
  x86_64)
    PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/xemu-${PKG_VERSION}-x86_64.AppImage"
  ;;
  aarch64)
    PKG_URL="https://github.com/ROCKNIX/packages/raw/refs/heads/main/xemu-aarch64.tar.gz"
  ;;
esac

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/start_xemu.sh ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/xemu-sa
  case ${TARGET_ARCH} in
    x86_64)
      cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/share/xemu-sa/${PKG_NAME}
      APPIMAGE=${PKG_NAME}
    ;;
    aarch64)
      cp -r ${PKG_BUILD}/xemu ${INSTALL}/usr/share/xemu-sa/
      cp -r ${PKG_BUILD}/license.txt ${INSTALL}/usr/share/xemu-sa/
      APPIMAGE="xemu"
    ;;
  esac
  sed -e "s/@APPIMAGE@/${APPIMAGE}/g" -i ${INSTALL}/usr/bin/start_xemu.sh
  chmod 755 ${INSTALL}/usr/bin/*
  chmod 755 ${INSTALL}/usr/share/xemu-sa/*

  mkdir -p ${INSTALL}/usr/config/xemu
  cp -rf ${PKG_DIR}/config/${DEVICE}/xemu.toml ${INSTALL}/usr/config/xemu

  #Download HDD IMAGE
  curl -Lo ${INSTALL}/usr/config/xemu/hdd.zip ${PKG_HDD_IMAGE}
}
