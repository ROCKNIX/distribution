# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="picodrive-lr"
PKG_VERSION="733c711a477a642fd2006d5a7a581b2790ec36b4"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/picodrive"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro implementation of PicoDrive. (Sega Megadrive/Genesis/Sega Master System/Sega GameGear/Sega CD/32X)"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro -C .."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/picodrive_libretro.so ${INSTALL}/usr/lib/libretro
}
