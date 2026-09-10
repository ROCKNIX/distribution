# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="prboom-lr"
PKG_VERSION="861959f30fe0d5d2192ff54c4850c62824299e58"
PKG_SHA256="4f8a352f60b6b9ba75a50e3197b767e1bb5ce6af56ebdf746e3aad52bf1647ab"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-prboom"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro implementation of Doom"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a prboom_libretro.so ${INSTALL}/usr/lib/libretro/prboom_libretro.so
}
