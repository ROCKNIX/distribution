# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="neocd_lr"
PKG_VERSION="8f2d42c1cebc802d00ef8c74c24ea6b2e1b9f931"
PKG_SHA256="05283c5d35f7cfdc447b3a45631983a82f155c5048f390d1a85e088bd3966b35"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/neocd_libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain flac libogg libvorbis"
PKG_LONGDESC="Neo Geo CD emulator for libretro "

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/neocd_libretro.so ${INSTALL}/usr/lib/libretro
}
