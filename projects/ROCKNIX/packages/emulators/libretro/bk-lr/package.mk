# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bk-lr"
PKG_VERSION="fe64da42ee463c1b2f4d0566e4d0f7a9667506f6"
PKG_SHA256="bccd1788516c952001d362f8661d7a88539dcf2bf45e25b0e25584ff4e86721b"
PKG_LICENSE="HPND"
PKG_SITE="https://github.com/libretro/bk-emulator"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Linux/SDL emulator for Soviet (russian) Electronica BK serie"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/bk_libretro.so ${INSTALL}/usr/lib/libretro
}
