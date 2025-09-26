# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="duckstation-sa"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_VERSION="0.1-9669"
PKG_LONGDESC="Fast PlayStation 1 emulator for x86-64/AArch32/AArch64 "
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/DuckStation-x64.AppImage"
  ;;
  aarch64)
    PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/DuckStation-Mini-arm64.AppImage"
  ;;
esac

install_script() {
  if [ ! -d "${INSTALL}/usr/config/modules" ]
  then
    mkdir -p ${INSTALL}/usr/config/modules
  fi
  cp -rf ${PKG_DIR}/sources/"${1}" ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/"${1}"
}

makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/*.sh ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/duckstation
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/duckstation

  install_script "Start Duckstation.sh"
}
