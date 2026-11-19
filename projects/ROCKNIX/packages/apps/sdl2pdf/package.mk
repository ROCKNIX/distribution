# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sdl2pdf"
PKG_VERSION="v0.1"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_ttf"
PKG_LONGDESC="Simple SDL2 PDF viewer"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -a ${PKG_BUILD}/sdl2pdf ${INSTALL}/usr/bin
}
