# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="screen-switch"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain sway"
PKG_LONGDESC="A simple script to swap sway output screens"
PKG_TOOLCHAIN="manual"
PKG_PATCH_DIRS+="${DEVICE}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/screen_switch ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*
}
