# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="control-gen"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Generates control.txt for gptokeyb"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/control-gen ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
