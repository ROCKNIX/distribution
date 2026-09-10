# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="opera-lr"
PKG_VERSION="a501a278d057b952d1ad6165549c59ab178ca497"
PKG_SHA256="3e85e640401b970445a68120d7c7fe1e68e0e9b4bbfbb0dd99a98f97b23a76d5"
PKG_LICENSE="LGPL with additional notes"
PKG_SITE="https://github.com/libretro/opera-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of 4DO/libfreedo to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a opera_libretro.so ${INSTALL}/usr/lib/libretro
}
