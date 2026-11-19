# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/chrome-depends/libXcursor/package.mk

post_makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include/X11/Xcursor
    cp include/X11/Xcursor/Xcursor.h ${SYSROOT_PREFIX}/usr/include/X11/Xcursor

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp xcursor.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp src/.libs/libXcursor.la ${SYSROOT_PREFIX}/usr/lib
    cp src/.libs/libXcursor.so* ${SYSROOT_PREFIX}/usr/lib
}
