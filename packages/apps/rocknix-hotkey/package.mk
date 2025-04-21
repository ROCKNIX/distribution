# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-hotkey"
PKG_VERSION="221103e20eaaad4c9c659bcfee508752938313e2"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ROCKNIX/rocknix-hotkey"
PKG_URL="https://github.com/ROCKNIX/rocknix-hotkey/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 control-gen"
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  CFLAGS+=" -I$(get_build_dir SDL2)/include -D_REENTRANT"
  CFLAGS+=" -I$(get_build_dir libevdev)"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P ${PKG_BUILD}/gptokeyb ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/gptokeyb/
  cp ${PKG_BUILD}/configs/default.gptk ${INSTALL}/usr/config/gptokeyb
}
