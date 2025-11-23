# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/compress/libarchive/package.mk

PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET/-DBUILD_SHARED_LIBS=OFF/-DBUILD_SHARED_LIBS=ON}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -rf libarchive/libarchive.so* ${INSTALL}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -rf libarchive/libarchive.so* ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp build/pkgconfig/libarchive.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig

  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp ${PKG_BUILD}/libarchive/{archive.h,archive_entry.h} ${SYSROOT_PREFIX}/usr/include
}
