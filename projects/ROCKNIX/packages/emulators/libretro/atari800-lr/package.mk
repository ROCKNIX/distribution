# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="atari800-lr"
PKG_VERSION="4e7fbc73765c1a9670c7506616046ad1d4ccda51"
PKG_SHA256="475f072f17059a23f402ee2744c00476aba5b7c819b1af3b38c933e45bdf2947"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-atari800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="atari800 3.1.0 for libretro/libco WIP"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a atari800_libretro.so ${INSTALL}/usr/lib/libretro
}
