# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-vb-lr"
PKG_VERSION="83ed42608601fb7b01d41e4f8fb2007a37b8c84e"
PKG_SHA256="02630caca19b3e5ba4a1132c78cca7c2ac7238169f7014d8f345b86540ce4fc7"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-vb-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of Mednafen VB. (VirtualBoy)"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_vb_libretro.so ${INSTALL}/usr/lib/libretro/beetle_vb_libretro.so
}
