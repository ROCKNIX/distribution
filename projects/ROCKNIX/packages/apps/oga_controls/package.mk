# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="oga_controls"
PKG_VERSION="1604ee24150c1c5bb7c66bc4670919c2ad8f0064"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/christianhaitian/oga_controls"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="universal"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2"
PKG_LONGDESC="Emulated keyboard / mouse / joystick for the RGB10/OGA 1.1 (BE), RG351 P/M/V, RK2020/OGA 1.0, OGS, and the Chi"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"
PKG_PATCH_DIRS+="${DEVICE}"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  CFLAGS+=" -I${SYSROOT_PREFIX}/usr/include/SDL2 -D_REENTRANT"
  CFLAGS+=" -I${SYSROOT_PREFIX}/usr/include/libevdev-1.0"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/oga_controls* ${INSTALL}/usr/bin
}
