# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="xmil-lr"
PKG_VERSION="3106aa54ffb244cca4019a6e95dacaa698781bc3"
PKG_SHA256="3b0d4a94d3ba8293dbbe6e1dd7bd1cdd8ad3d70b52dc248299380d86b3e70812"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/libretro/xmil-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro port of X Millennium Sharp X1 emulator"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/libretro/x1_libretro.so ${INSTALL}/usr/lib/libretro
}
