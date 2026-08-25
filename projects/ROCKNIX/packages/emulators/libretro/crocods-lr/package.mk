# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="crocods-lr"
PKG_VERSION="a9c63b29443715ae2add392010fca4eae7f93e67"
PKG_SHA256="e2d2ce649fa390e277ea7db15d376027b1f69b42c4767c5551e972015c6d2768"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/libretro-crocods"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Amstrad CPC emulator"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a crocods_libretro.so ${INSTALL}/usr/lib/libretro
}
