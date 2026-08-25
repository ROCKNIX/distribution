# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gearboy-lr"
PKG_VERSION="542f60b7065612cf318986baf5c87ab64075f2aa"
PKG_SHA256="c4cc7cad99bfa84b4dcf7860eeefc12ef181d4c21798445abbfa71060a01370f"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/drhelius/Gearboy"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Game Boy / Gameboy Color emulator for iOS, Mac, Raspberry Pi, Windows and Linux"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platforms/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platforms/libretro/gearboy_libretro.so ${INSTALL}/usr/lib/libretro
}
