# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mako-notify"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain dbus"
PKG_LONGDESC="Tool to show onscreen messages in sway, via the mako-osd tool"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/mako-notify ${INSTALL}/usr/bin
}
