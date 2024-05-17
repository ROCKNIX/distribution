# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="device-switch"
PKG_VERSION=""
PKG_LICENSE="mix"
PKG_DEPENDS_TARGET="toolchain"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Support script for switching device dtbs"
PKG_TOOLCHAIN="manual"

makeinstall_target() {

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/${DEVICE}/device-switch ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*
}
