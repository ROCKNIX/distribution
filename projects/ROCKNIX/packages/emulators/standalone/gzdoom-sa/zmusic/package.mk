# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="zmusic"
PKG_VERSION="1.1.14"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ZDoom/ZMusic"
PKG_URL="https://github.com/ZDoom/ZMusic/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host glib:host"
PKG_DEPENDS_TARGET="toolchain zmusic:host glib"
PKG_LONGDESC="GZDoom's music system as a standalone library"
PKG_TOOLCHAIN="cmake-make"

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/usr/{lib,include}
    cp -a ${PKG_BUILD}/.${HOST_NAME}/source/libzmusic* ${TOOLCHAIN}/usr/lib
    cp -a ${PKG_BUILD}/include/zmusic.h ${TOOLCHAIN}/usr/include
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/{lib,include}
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/source/libzmusic* ${SYSROOT_PREFIX}/usr/lib
    cp -a ${PKG_BUILD}/include/zmusic.h ${SYSROOT_PREFIX}/usr/include

  mkdir -p ${INSTALL}/usr/lib
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/source/libzmusic* ${INSTALL}/usr/lib
}
