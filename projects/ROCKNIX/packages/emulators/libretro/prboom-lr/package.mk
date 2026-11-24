# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="prboom-lr"
PKG_VERSION="4849268e7342494193f2bbf2d0128a751cf58da7"
PKG_SHA256="36a069cf09053388d719e2694a509cb8d2d152137b66adbef8fccba8373f8879"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-prboom"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="libretro implementation of Doom"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a prboom_libretro.so ${INSTALL}/usr/lib/libretro/prboom_libretro.so
}
