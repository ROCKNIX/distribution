# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="neocd_lr"
PKG_VERSION="5eca2c8fd567b5261251c65ecafa8cf5b179d1d2"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/libretro/neocd_libretro"
PKG_URL="https://github.com/libretro/neocd_libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain flac libogg libvorbis"
PKG_LONGDESC="Neo Geo CD emulator for libretro "
PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}
  CFLAGS=${CFLAGS} CXXFLAGS="${CXXFLAGS}" CXX="${CXX}" CC="${CC}" LD="$LD" RANLIB="$RANLIB" AR="${AR}" make
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/neocd_libretro.so ${INSTALL}/usr/lib/libretro
}
