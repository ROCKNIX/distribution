# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mako-notify"
PKG_VERSION="v1.0"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Tool to show onscreen messages in sway, via the mako-osd tool"
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  cp -f ${PKG_DIR}/mako-notify.cpp ${PKG_BUILD}
  CFLAGS+=" -D_REENTRANT"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -r  ${PKG_BUILD}/mako-notify ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin
}
