# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="snes9x-lr"
PKG_VERSION="890b5d445538fe790aa3add3d5702c80f551e0ae"
PKG_SHA256="fcc32b536d3e7b1def0d15489917dd043d5e1d9636de8af7851c48e771276613"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/snes9x"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Snes9x - Portable Super Nintendo Entertainment System (TM) emulator"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a libretro/snes9x_libretro.so ${INSTALL}/usr/lib/libretro
}
