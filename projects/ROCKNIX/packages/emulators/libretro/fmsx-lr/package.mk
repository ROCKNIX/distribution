# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fmsx-lr"
PKG_VERSION="f013e213458e06d9df718e4bc4b09d46f88aa899"
PKG_SHA256="ddd0b48489da2498feff8d3613c0471367d23d9fe331d1367ecf199360ee87f8"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/fmsx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of fMSX 4.9 to the libretro API."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a fmsx_libretro.so ${INSTALL}/usr/lib/libretro
}
