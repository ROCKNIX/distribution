# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="stella-lr"
PKG_VERSION="514efcfea1216d43b0ed9068669a5d456e011c26"
PKG_SHA256="0708fe92cd2301c0b8fe8785601c2a1ab6f3e480516a0343c38ee9791fd6a753"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/stella-emu/stella"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Port of Stella to libretro."
PKG_TOOLCHAIN="make"

case ${TARGET_ARCH} in
  aarch64) PKG_MAKE_OPTS_TARGET=" -C ../src/os/libretro platform=aarch64" ;;
  *) PKG_MAKE_OPTS_TARGET=" -C ../src/os/libretro" ;;
esac

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../src/os/libretro/stella_libretro.so ${INSTALL}/usr/lib/libretro
}

