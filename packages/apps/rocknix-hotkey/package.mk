# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="rocknix-hotkey"
PKG_VERSION="221103e20eaaad4c9c659bcfee508752938313e2"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ROCKNIX/rocknix-hotkey"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 control-gen"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  CFLAGS+=" -I$(get_build_dir SDL2)/include -D_REENTRANT"
  CFLAGS+=" -I$(get_build_dir libevdev)"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/gptokeyb ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/gptokeyb/
  cp ${PKG_BUILD}/configs/default.gptk ${INSTALL}/usr/config/gptokeyb/
}
