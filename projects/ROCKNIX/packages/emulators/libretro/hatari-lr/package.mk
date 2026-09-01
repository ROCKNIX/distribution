# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hatari-lr"
PKG_VERSION="24e7bd744f24f20b464385f365a3850c269bd140"
PKG_SHA256="f45c64793a082f1d5a33cb32560276cfd32945912c958066e422f819489817d8"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/hatari"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain capsimg"
PKG_LONGDESC="New rebasing of Hatari based on Mercurial upstream. Tries to be a shallow fork for easy upstreaming later on."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C .. -f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../hatari_libretro.so ${INSTALL}/usr/lib/libretro

  mkdir -p ${INSTALL}/usr/config/game/configs/hatari
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/game/configs/hatari/
}
