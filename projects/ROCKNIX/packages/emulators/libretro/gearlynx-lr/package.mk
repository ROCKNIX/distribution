# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gearlynx-lr"
PKG_VERSION="6b8c8f781e430f5e5ec4bff48111b5b8927e4ca2"
PKG_SHA256="4e5ff95ef0693abc3d49138d5ee759d31b839ec58b884527a9bd8a6d826176f2"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/drhelius/Gearlynx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Gearlynx is a very accurate, cross-platform Atari Lynx emulator written in C++ that runs on Windows, macOS, Linux, BSD and RetroArch."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platforms/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platforms/libretro/gearlynx_libretro.so ${INSTALL}/usr/lib/libretro
}
