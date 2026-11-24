# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-supergrafx-lr"
PKG_VERSION="9c11dcd213a79d57d2c86313971631af801f2cdc"
PKG_SHA256="7fbe720bd6173bac54e76b1f772b11179a3c5aae0f2d6e14f040df71311e2976"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-supergrafx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Standalone port of Mednafen PCE Fast to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_supergrafx_libretro.so ${INSTALL}/usr/lib/libretro/beetle_supergrafx_libretro.so
}
