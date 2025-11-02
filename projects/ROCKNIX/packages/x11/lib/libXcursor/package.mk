# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libXcursor"
PKG_VERSION="1.2.1"
PKG_SHA256="46c143731610bafd2070159a844571b287ac26192537d047a39df06155492104"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/lib/libXcursor-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libX11 libXfixes libXrender"
PKG_LONGDESC="X11 Cursor management library.s"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic -sysroot"

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include/X11/Xcursor
    cp include/X11/Xcursor/Xcursor.h ${SYSROOT_PREFIX}/usr/include/X11/Xcursor

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp xcursor.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp src/.libs/libXcursor.la ${SYSROOT_PREFIX}/usr/lib
    cp src/.libs/libXcursor.so* ${SYSROOT_PREFIX}/usr/lib
}
