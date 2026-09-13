# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="heroic"
PKG_VERSION="1.0"
PKG_LICENSE="proprietary"
PKG_SITE="https://heroicgameslauncher.com"
PKG_LONGDESC="Heroic Games Launcher runtime scripts for ROCKNIX"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
