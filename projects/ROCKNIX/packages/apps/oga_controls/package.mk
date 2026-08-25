# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="oga_controls"
PKG_VERSION="1604ee24150c1c5bb7c66bc4670919c2ad8f0064"
PKG_SHA256="cdfa89581e3494220ef1d91246376179947bdd2ba1dd084249c224cc9ce0d8f4"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/christianhaitian/oga_controls"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2"
PKG_LONGDESC="Emulated keyboard / mouse / joystick for the RGB10/OGA 1.1 (BE), RG351 P/M/V, RK2020/OGA 1.0, OGS, and the Chi"
PKG_TOOLCHAIN="make"

PKG_PATCH_DIRS+="${DEVICE}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/oga_controls ${INSTALL}/usr/bin
}
