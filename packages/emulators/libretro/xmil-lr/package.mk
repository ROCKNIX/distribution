# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="xmil-lr"
PKG_VERSION="6a52dc21a5ff106137670bb600ab2ce3fcebeb1b"
PKG_LICENSE="Unknown"
PKG_SITE="https://github.com/libretro/xmil-libretro"
PKG_URL="https://github.com/libretro/xmil-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro port of X Millennium Sharp X1 emulator"
PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}
  make -C libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/libretro/x1_libretro.so ${INSTALL}/usr/lib/libretro
}
