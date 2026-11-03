# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="opera-lr"
PKG_VERSION="54fe4f3754e9b69c83ff50b5def5d6c60fef06ce"
PKG_SHA256="1034d58acb38cd9fcb08da6d90980edd6a0439aaa9d47735f1c85d8e6143122b"
PKG_LICENSE="LGPL with additional notes"
PKG_SITE="https://github.com/libretro/opera-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Port of 4DO/libfreedo to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a opera_libretro.so ${INSTALL}/usr/lib/libretro
}
