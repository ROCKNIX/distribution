# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bsnes2014-accuracy-lr"
PKG_VERSION="3beff8ebfa91d6faaf8b854140fbcb7542a3c516"
PKG_SHA256="39b329918124d39f33267f04b5e7a1fec5561b9c37da47ffd7edcc59fc1abf49"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/bsnes2014"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro fork of bsnes. Built for accuracy."
PKG_TOOLCHAIN="make"

make_target() {
  make PROFILE=accuracy
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -f bsnes2014_accuracy_libretro.so ${INSTALL}/usr/lib/libretro
}
