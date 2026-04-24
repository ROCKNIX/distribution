# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libndp"
PKG_VERSION="1.9"
PKG_LICENSE="LGPL-2.1"
PKG_SITE="https://github.com/jpirko/libndp"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Library providing a wrapper for IPv6 Neighbor Discovery Protocol"
PKG_TOOLCHAIN="autotools"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/lib/pkgconfig
  find ${INSTALL}/usr/lib -name "*.a" -delete
  find ${INSTALL}/usr/lib -name "*.la" -delete
  rm -f ${INSTALL}/usr/sbin/ndptool
}
