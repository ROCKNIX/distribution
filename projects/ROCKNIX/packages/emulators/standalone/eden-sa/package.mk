# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="eden-sa"
PKG_LICENSE="GPLv3"
PKG_LONGDESC="Eden is the world's most popular open-source Nintendo Switch emulator, forked from the Yuzu emulator."
PKG_TOOLCHAIN="manual"
PKG_SITE="https://git.eden-emu.dev/eden-emu/eden"
PKG_VERSION="v0.2.0-rc1"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/Eden-Linux-${PKG_VERSION}-aarch64-clang-pgo.AppImage"

makeinstall_target() {
  export STRIP=true
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/${PKG_NAME}-${PKG_VERSION}.AppImage ${INSTALL}/usr/bin/eden
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config/eden
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/eden/
}

