# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="heroic"
PKG_LICENSE="GPLv2"
PKG_SITE="https://heroicgameslauncher.com"
PKG_LONGDESC="Heroic Games Launcher runtime scripts for ROCKNIX"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -f ${PKG_DIR}/scripts/*.sh ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/*.sh
}
