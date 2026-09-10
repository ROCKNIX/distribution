# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-gba-lr"
PKG_VERSION="bb9edd1d611f245cd5aeb0b39986f2ecf6ec843f"
PKG_SHA256="3ba3246a2915d3422da92f554c27fe2f08c969d9ee8e8269340de60280afe398"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-gba-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of Mednafen VBA/GBA. (Game Boy Advance)"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_gba_libretro.so ${INSTALL}/usr/lib/libretro/beetle_gba_libretro.so
}
