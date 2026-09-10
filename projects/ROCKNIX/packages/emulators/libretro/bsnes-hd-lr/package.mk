# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bsnes-hd-lr"
PKG_VERSION="fc26b25ea236f0f877f0265d2a2c37dfd93dfde9"
PKG_SHA256="0cf48d8ef4846ce2b0b26fac4068cfbe2ab4c90794ede1af66c343fbfe079b2f"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/DerKoun/bsnes-hd"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="bsnes-hd is a fork of bsnes that adds HD video features such as widescreen, HD Mode 7 and true color"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C bsnes target=libretro compiler=${TARGET_NAME}-g++"

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/bsnes/GNUmakefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a bsnes/out/bsnes_hd_beta_libretro.so ${INSTALL}/usr/lib/libretro
}

