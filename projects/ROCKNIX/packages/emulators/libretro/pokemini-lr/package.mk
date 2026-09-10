# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pokemini-lr"
PKG_VERSION="132111b76343559860532a1ccc094f93f1ed5650"
PKG_SHA256="53d1266404a823d1cf11b66b0d837c34604fa1623576275e52ec796b663ca2cf"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/pokemini"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Obscure nintendo AMD64 emulator (functional,no color files or savestates currently)"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a pokemini_libretro.so ${INSTALL}/usr/lib/libretro
}
