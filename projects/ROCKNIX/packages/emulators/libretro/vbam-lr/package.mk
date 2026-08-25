# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vbam-lr"
PKG_VERSION="115defb3a318258ab84746d45258a1aec19d0b4b"
PKG_SHA256="92479e6e248e94d202b6478f407cbf8ef5b317ddb1247961555cc0d2f0c40a27"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/vbam-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fork of VBA-M with libretro integration"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C ../src/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../src/libretro/vbam_libretro.so ${INSTALL}/usr/lib/libretro
}
