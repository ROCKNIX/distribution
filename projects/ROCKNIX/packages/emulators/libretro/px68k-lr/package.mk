# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="px68k-lr"
PKG_VERSION="d22f6a2e9111754e88a72b49b292c238fd32dc61"
PKG_SHA256="a7b34f42503ec93d51d99e4a17a68ea7f58ec937fd068096cfe9214e3fe3e99a"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/px68k-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Portable SHARP X68000 Emulator for PSP, Android and other platforms"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a px68k_libretro.so ${INSTALL}/usr/lib/libretro
}
