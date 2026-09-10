# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="stella-lr"
PKG_VERSION="c1ffb833c8b180433b0cad76bb6b55f8dfbc46ee"
PKG_SHA256="bd515308f726ac06a6f6e50fa6919ed093a44406a096c6c79b09d4dd1fe872e4"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/stella-emu/stella"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
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

