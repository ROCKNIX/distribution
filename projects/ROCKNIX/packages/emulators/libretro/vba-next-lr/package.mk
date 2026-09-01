# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vba-next-lr"
PKG_VERSION="2b96fd3a77025f3083daf61126b1852d5e0eace7"
PKG_SHA256="f4007a96d4d1280e7ac8a5552a99233bfa41475dd3a6f5865444107e77430f34"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/vba-next"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Optimized port of VBA-M to Libretro."

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a vba_next_libretro.so ${INSTALL}/usr/lib/libretro
}
