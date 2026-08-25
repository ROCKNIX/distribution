# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retropie-shaders"
PKG_VERSION="43eaf9b91857eb8515310c74ae750895d77b20f8"
PKG_SHA256="4bc1bc61604e91fe314cf781d05b3b99e1991e65a6adafcb8464e633e156a58e"
PKG_LICENSE=""
PKG_SITE="https://github.com/RetroPie/common-shaders"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="Libretro common shaders from retropie"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/common-shaders
    cp -a ${PKG_BUILD}/* ${INSTALL}/usr/share/common-shaders
    rm -f ${INSTALL}/usr/share/common-shaders/{Makefile,configure}
}
