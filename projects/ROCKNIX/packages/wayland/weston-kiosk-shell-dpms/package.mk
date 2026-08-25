# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="weston-kiosk-shell-dpms"
PKG_VERSION="1273a6ed6a3fdd7af9e3d5d70b4ef40ecb929309"
PKG_SHA256="db8fad234a8fde069217986f44134f619bd475fb89aa95f8b9c419cf11ae992f"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/akhilharihar/Weston-kiosk-shell-DPMS"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ${WINDOWMANAGER}"
PKG_LONGDESC="A dpms module for Weston's kiosk shell."

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/weston-dpms ${INSTALL}/usr/bin
}
