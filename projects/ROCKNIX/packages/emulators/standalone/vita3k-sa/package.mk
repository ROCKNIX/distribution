# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vita3k-sa"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Vita3K/Vita3K"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 qt6 mesa libcom-err"
PKG_LONGDESC="PS VITA Emulator appimage"
PKG_TOOLCHAIN="manual"
PKG_VERSION="CI"
PKG_REL_VERSION="CI"
PKG_URL="${PKG_SITE}/releases/download/continuous/Vita3k-aarch64.AppImage"


makeinstall_target() {
  # Redefine strip or the AppImage will be stripped rendering it unusable.
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/vita3k
  mkdir -p ${INSTALL}/usr/config/vita3k/sources
  mkdir -p ${INSTALL}/storage/bios/vita3k
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/${PKG_NAME}
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
  chmod 755 ${INSTALL}/usr/bin/*
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/vita3k/
  cp ${PKG_DIR}/sources/vita-gamelist.txt ${INSTALL}/usr/config/vita3k/sources/vita-gamelist.txt

}
