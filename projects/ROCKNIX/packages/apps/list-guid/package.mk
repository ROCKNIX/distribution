# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="list-guid"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_SITE="http://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Simple SDL tool to create a list off GUIDs for all connected gamepads."
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/list-guid ${INSTALL}/usr/bin
}
