# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gearsystem-lr"
PKG_VERSION="1c090b698bb910c053cc9b10bc67c1a5612cb054"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/drhelius/Gearsystem"
PKG_URL="https://github.com/drhelius/Gearsystem/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Gearsystem is a Sega Master System / Game Gear / SG-1000 emulator written in C++"
PKG_TOOLCHAIN="make"

make_target() {
  make -C platforms/libretro
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp platforms/libretro/gearsystem_libretro.so ${INSTALL}/usr/lib/libretro
}
