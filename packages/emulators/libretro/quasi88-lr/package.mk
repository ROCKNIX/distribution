# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="quasi88-lr"
PKG_VERSION="28b37bafd3fb1e3a812c50a5ddca94c5fd68e5fd"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/libretro/quasi88-libretro"
PKG_URL="https://github.com/libretro/quasi88-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp quasi88_libretro.so ${INSTALL}/usr/lib/libretro
}
