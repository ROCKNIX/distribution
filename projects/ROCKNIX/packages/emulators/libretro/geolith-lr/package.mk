# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="geolith-lr"
PKG_VERSION="2dc88e3fa72ff404213a65d6eb5bb33baa687f73"
PKG_SHA256="8bf3f36e5edc38ed8d694f24ed02a61fae2a1a4abfba11f03e01daa311878e66"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/libretro/geolith-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Geolith is a highly accurate emulator for the Neo Geo AES, MVS, CD, and CDZ."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C libretro platform=${DEVICE}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a libretro/geolith_libretro.so ${INSTALL}/usr/lib/libretro
}
