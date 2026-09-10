# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-pce-fast-lr"
PKG_VERSION="bebe2b13a840fbfd45cb501f5cd0efe01bdb1735"
PKG_SHA256="509ce18c6d1191fdea45ce45d2f1224de6b3cd15a8acd53a8816a8ac6a191e35"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-pce-fast-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Standalone port of Mednafen PCE Fast to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_pce_fast_libretro.so ${INSTALL}/usr/lib/libretro/beetle_pce_fast_libretro.so
}
