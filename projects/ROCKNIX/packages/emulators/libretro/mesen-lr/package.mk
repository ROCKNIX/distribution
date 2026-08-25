# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mesen-lr"
PKG_VERSION="0102910c39ad1a62bc3f784466f3f67ca9eae335"
PKG_SHA256="360f97e907ada9b8e28a95652aa1d07656340e1d84ff868312745a566b250e01"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/Mesen"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Mesen is a cross-platform NES/Famicom emulator for Windows & Linux built in C++ and C#."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C Libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a Libretro/mesen_libretro.so ${INSTALL}/usr/lib/libretro
}
