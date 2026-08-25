# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bsnes-lr"
PKG_VERSION="b102d6d5817b25aa059b573cd3b7675f2e375fa4"
PKG_SHA256="14b2dfe099d0456f1f9ecb1f5e0b925d55f898df0000f329339be2b84bf84bf1"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/bsnes-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="BSNES Super Nintendo Libretro Core"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a bsnes_libretro.so ${INSTALL}/usr/lib/libretro
}

