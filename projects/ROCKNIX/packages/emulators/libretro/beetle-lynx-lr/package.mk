# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-lynx-lr"
PKG_VERSION="fcdefcfb3c11d6d2e71be076a5d3df2e88ab73ed"
PKG_SHA256="3dd45a6f6585c444a415cb097996c572467754748e7163eca466d89b31bd8b37"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-lynx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of Mednafen Lynx"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_lynx_libretro.so ${INSTALL}/usr/lib/libretro/beetle_lynx_libretro.so
}
