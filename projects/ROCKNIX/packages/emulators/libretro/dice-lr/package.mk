# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dice-lr"
PKG_VERSION="b11714fc4eb5b671ba15f2ec7b98c7ae909f7a4c" # v0.4.2 + frame size fix
PKG_SHA256="ee167b7eba044c8297c3c51cc5d3b6c7afb496a8363432698f39fbcc2c09bd61"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/mittonk/dice-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="DICE, a Discrete Integrated Circuit Emulator for CPU-less arcade games such as Pong"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a dice_libretro.so ${INSTALL}/usr/lib/libretro
}
