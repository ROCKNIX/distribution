# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-ngp-lr"
PKG_VERSION="a50d5ac288a81f2104ddf43195a4efdd15c72227"
PKG_SHA256="ffeabf2a357548f3a55423d542c31bb1e08571d81d7104f8213df3bfa2eb9c9f"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-ngp-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of Mednafen Neo Geo Pocket."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_ngp_libretro.so ${INSTALL}/usr/lib/libretro/beetle_ngp_libretro.so
}
