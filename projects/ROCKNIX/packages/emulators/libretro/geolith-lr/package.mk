# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="geolith-lr"
PKG_VERSION="20aa7cd25d1d0e053f9a363275c96bde9658e36d"
PKG_SHA256="6dbfa296f444a8d9ba690fad2ae9bec89d36b23d68c6bebd9902abd022e0b7d8"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/libretro/geolith-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Geolith is a highly accurate emulator for the Neo Geo AES, MVS, CD, and CDZ."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C libretro platform=${DEVICE}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a libretro/geolith_libretro.so ${INSTALL}/usr/lib/libretro
}
