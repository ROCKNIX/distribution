# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="arduous-lr"
PKG_VERSION="798e3950f1de7c69455bc988d55eafeebac5a1eb"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/arduous"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Libretro emulator core for the Arduboy"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a arduous_libretro.so ${INSTALL}/usr/lib/libretro
}
