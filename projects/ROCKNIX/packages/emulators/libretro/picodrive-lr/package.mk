# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="picodrive-lr"
PKG_VERSION="07abb00550528f7bf53087d932dd3d747cf2d0df"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/irixxxx/picodrive"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Libretro implementation of PicoDrive. (Sega Megadrive/Genesis/Sega Master System/Sega GameGear/Sega CD/32X)"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro -C .."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/picodrive_libretro.so ${INSTALL}/usr/lib/libretro
}
