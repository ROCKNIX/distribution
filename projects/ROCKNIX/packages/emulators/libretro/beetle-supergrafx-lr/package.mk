# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-supergrafx-lr"
PKG_VERSION="3c6fcd3deded54ebecd69408f108407ac03d11b5"
PKG_SHA256="87c5355089ad3d60befd76c2227062e48d6db5a33ab46e4b3efd680cb55a9ee9"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-supergrafx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Standalone port of Mednafen PCE Fast to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_supergrafx_libretro.so ${INSTALL}/usr/lib/libretro/beetle_supergrafx_libretro.so
}
