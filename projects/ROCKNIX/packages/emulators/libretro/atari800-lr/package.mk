# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="atari800-lr"
PKG_VERSION="cd721790a0aa0e0772810949abcf5bd699c15371"
PKG_SHA256="51493acb0894097717ecf4c2039a14ebb171f42a046c6833118746ed6885fdbc"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-atari800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="atari800 3.1.0 for libretro/libco WIP"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a atari800_libretro.so ${INSTALL}/usr/lib/libretro
}
