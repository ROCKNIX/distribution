# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sdl2text"
PKG_VERSION="v1.0"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf"
PKG_LONGDESC="SDL2 text reader with gamepad controls"
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  cp -f ${PKG_DIR}/sdl2text.cpp ${PKG_BUILD}
  CFLAGS+=" -I$(get_build_dir SDL2)/include -D_REENTRANT"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/sdl2text ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*
}
