# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="common-shaders"
PKG_VERSION="86cfa146a8dfddf6377ddb5dbcff552feae2e5bf"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/common-shaders"
PKG_URL="https://github.com/libretro/common-shaders/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro common shaders"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/common-shaders
  cp -rf ${BUILD}/${PKG_NAME}-${PKG_VERSION}/* ${INSTALL}/usr/share/common-shaders
  rm -f ${INSTALL}/usr/share/common-shaders/{Makefile,configure}
}
