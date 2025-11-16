# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="weston-kiosk-shell-dpms"
PKG_VERSION="1273a6ed6a3fdd7af9e3d5d70b4ef40ecb929309"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/akhilharihar/Weston-kiosk-shell-DPMS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ${WINDOWMANAGER}"
PKG_LONGDESC="A dpms module for Weston's kiosk shell."

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/weston-dpms ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/weston-dpms
}
