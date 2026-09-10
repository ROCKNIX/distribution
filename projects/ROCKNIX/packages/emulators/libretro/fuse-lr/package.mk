# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fuse-lr"
PKG_VERSION="2a5f1d43fec729063203605c39cc40f2957c47a1"
PKG_SHA256="06db30dc6c67aabab0f438eeed19cb8d41dee375473f84922cdd792235068274"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/fuse-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A port of the Fuse Unix Spectrum Emulator to libretro "

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a fuse_libretro.so ${INSTALL}/usr/lib/libretro
}
