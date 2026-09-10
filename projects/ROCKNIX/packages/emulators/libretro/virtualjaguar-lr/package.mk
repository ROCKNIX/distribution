# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="virtualjaguar-lr"
PKG_VERSION="e6709d27bd4561d10b5ca72d94522471a6fd10af"
PKG_SHA256="1a10902e8b4c45e50d6df4d350fa58a2d6ed32cf86e9d78ba754f8636a67fe77"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/virtualjaguar-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of Virtual Jaguar to Libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a virtualjaguar_libretro.so ${INSTALL}/usr/lib/libretro
}
