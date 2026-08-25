# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="geolith-lr"
PKG_VERSION="39b96aebee7188126a7a5422cd978ac60e0cbb59"
PKG_SHA256="a42392b8b09f9b92ce95162c13f24b0d75e029bf6b0fdf3e039dc03dba7e3983"
PKG_ARCH="aarch64"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/libretro/geolith-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Geolith is a highly accurate emulator for the Neo Geo AES, MVS, CD, and CDZ."
PKG_TOOLCHAIN="make"

make_target() {
cd libretro
  make -f ./Makefile platform=${DEVICE}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp geolith_libretro.so ${INSTALL}/usr/lib/libretro/
}
