# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="rocknix-hotkey"
PKG_VERSION="b40b2e02c3c4fad17a0d1f58fc385f168bf98599"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ROCKNIX/rocknix-hotkey"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 control-gen"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/gptokeyb ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib
  cp ${PKG_BUILD}/inputfilter.so ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/usr/config/gptokeyb/
  cp ${PKG_BUILD}/configs/default.gptk ${INSTALL}/usr/config/gptokeyb/
}
