# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="common-shaders"
PKG_VERSION="86cfa146a8dfddf6377ddb5dbcff552feae2e5bf"
PKG_SHA256="294318654059f7d7bbe99e73daf25eb702561ec8d366f0d8c4498456e11a5b9f"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/common-shaders"
PKG_URL="https://github.com/libretro/common-shaders/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Libretro common shaders"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/common-shaders
    cp -PR ${PKG_BUILD}/* ${INSTALL}/usr/share/common-shaders
    rm -f ${INSTALL}/usr/share/common-shaders/{Makefile,configure}
}
