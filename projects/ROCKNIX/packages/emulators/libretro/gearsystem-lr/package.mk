# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gearsystem-lr"
PKG_VERSION="2c725424715dd41a5d6f8e97a4d318316cf9dbad"
PKG_SHA256="f6c46691e43950f4d80b1a848ea0539c1852da6602d10c2ffc6b94d9848c67dd"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/drhelius/Gearsystem"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Gearsystem is a Sega Master System / Game Gear / SG-1000 emulator written in C++"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platforms/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platforms/libretro/gearsystem_libretro.so ${INSTALL}/usr/lib/libretro
}
