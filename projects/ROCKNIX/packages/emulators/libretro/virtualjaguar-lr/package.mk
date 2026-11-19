# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="virtualjaguar-lr"
PKG_VERSION="ffea7893a59dd9b9e6f9b85c51627810338b0778"
PKG_SHA256="508c8cced12de59071b47e1d5c59d242fb9488ba088404e6a67558511fcbc5b9"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/virtualjaguar-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Port of Virtual Jaguar to Libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a virtualjaguar_libretro.so ${INSTALL}/usr/lib/libretro
}
