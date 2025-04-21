# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="oga_controls"
PKG_VERSION="1604ee24150c1c5bb7c66bc4670919c2ad8f0064"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/christianhaitian/oga_controls"
PKG_URL="https://github.com/christianhaitian/oga_controls/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libevdev"
PKG_LONGDESC="Emulated keyboard / mouse / joystick for the RGB10/OGA 1.1 (BE), RG351 P/M/V, RK2020/OGA 1.0, OGS, and the Chi"
PKG_TOOLCHAIN="make"
PKG_PATCH_DIRS+="${DEVICE}"

pre_make_target() {
  cp -f ${PKG_DIR}/Makefile ${PKG_BUILD}
  CFLAGS+=" -I$(get_build_dir SDL2)/include -D_REENTRANT"
  CFLAGS+=" -I$(get_build_dir libevdev)"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P ${PKG_BUILD}/oga_controls* ${INSTALL}/usr/bin
}
