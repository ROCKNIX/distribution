# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="tyrquake-lr"
PKG_VERSION="e57bb11597e8a00380f30f2627d219da960cf69a"
PKG_SHA256="6bedb86899ad6da030d15e11fa4a1a6b61db77a56d658d8de650f63afd1e166c"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/tyrquake"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro port of Tyrquake (Quake 1 engine)"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a tyrquake_libretro.so ${INSTALL}/usr/lib/libretro
}
