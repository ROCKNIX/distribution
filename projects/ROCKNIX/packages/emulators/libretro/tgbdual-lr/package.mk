# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="tgbdual-lr"
PKG_VERSION="0392c9c469e653205e471114c7949c07c83bfce9"
PKG_SHA256="4f6bc3e93664db811794369c9b0ebbcca59c2edf4df311f4312e309a3e2ed95c"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/tgbdual-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro port of TGB Dual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a tgbdual_libretro.so ${INSTALL}/usr/lib/libretro
}
