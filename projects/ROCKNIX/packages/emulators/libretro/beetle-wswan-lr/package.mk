# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-wswan-lr"
PKG_VERSION="4b01295838ea89e3f1355bbe4cb5cf98aa6108cd"
PKG_SHA256="bce15c0e2505e15b7b55fa1d51b4a12219d07a67be62bbca5c26678d0d89c659"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-wswan-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of Mednafen wswan"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_wswan_libretro.so ${INSTALL}/usr/lib/libretro/beetle_wswan_libretro.so
}
