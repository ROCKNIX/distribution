# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bsnes-mercury-accuracy-lr"
PKG_VERSION="60c204ca17941704110885a815a65c740572326f"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/bsnes-mercury"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="BSNES Super Nintendo Libretro Core"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

pre_make_target() {
    PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"
}

make_target() {
  make PROFILE=accuracy
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp bsnes_mercury_accuracy_libretro.so ${INSTALL}/usr/lib/libretro/
}

