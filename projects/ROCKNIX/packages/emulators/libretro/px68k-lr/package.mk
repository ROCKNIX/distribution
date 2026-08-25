# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="px68k-lr"
PKG_VERSION="0ad84d7058a12b7db4f7f7a906e87fad4e2f26f6"
PKG_SHA256="7d9b284f3a6cb388b7bfd159118ae4ecaf2660a7c0855e3babb208fc107b685d"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/px68k-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Portable SHARP X68000 Emulator for PSP, Android and other platforms"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a px68k_libretro.so ${INSTALL}/usr/lib/libretro
}
