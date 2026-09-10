# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="o2em-lr"
PKG_VERSION="679d6fec04963f6e70a7ec217e3d0ebb1fe472fc"
PKG_SHA256="d69453c179d1a4b63d3f937060bb255c3f02db904e7b2d22ae79042bce3997f1"
PKG_LICENSE="Artistic-2.0"
PKG_SITE="https://github.com/libretro/libretro-o2em"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of O2EM to the libretro API, an Odyssey 2 / VideoPac emulator."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a o2em_libretro.so ${INSTALL}/usr/lib/libretro
}
