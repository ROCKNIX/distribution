# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-hotkey"
PKG_VERSION="cc3a863199a71a350db05e9d0d0e646a8411332c"
PKG_SHA256="51220f0bcfd98659a591e8fad8bd767291b2db11225d17f44718481ac228f213"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ROCKNIX/rocknix-hotkey"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libevdev SDL2 control-gen"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/gptokeyb ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib
    cp -a ${PKG_BUILD}/inputfilter.so ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/usr/config/gptokeyb
    cp -a ${PKG_BUILD}/configs/default.gptk ${INSTALL}/usr/config/gptokeyb
}
