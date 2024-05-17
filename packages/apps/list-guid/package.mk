# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="list-guid"
PKG_VERSION="ea44ab254d09d2d86eeb70289673418df2beee75"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Simple SDL tool to create a list off GUIDs for all connected gamepads."
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  cp -f ${PKG_DIR}/list-guid.cpp ${PKG_BUILD}
  CFLAGS+=" -I$(get_build_dir SDL2)/include -D_REENTRANT"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/list-guid ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*
}
