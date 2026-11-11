# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="quasi88-lr"
PKG_VERSION="7884be5277776a5d8c4fdc4e574e9b5b589945c9"
PKG_SHA256="1bf45b4a87c96a7f6de212dde83f3c0e0cbc7023fac8e01e4f07da507c92273f"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/libretro/quasi88-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"

pre_configure_target() {
  CFLAGS="${CFLAGS} -std=gnu17"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a quasi88_libretro.so ${INSTALL}/usr/lib/libretro
}
