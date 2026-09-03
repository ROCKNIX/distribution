# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="snes9x2010-lr"
PKG_VERSION="7db129b1ecdccb38cb4d7184bcbed39beed79656"
PKG_SHA256="7443623d5c8a098fd20cf46dab29dbe8c7504f05d8a3aaa1a10f6d5d6a9d8d88"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/snes9x2010"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Snes9x 2010."

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a snes9x2010_libretro.so ${INSTALL}/usr/lib/libretro
}
