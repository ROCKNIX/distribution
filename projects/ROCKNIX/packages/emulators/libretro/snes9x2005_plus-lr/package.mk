# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="snes9x2005_plus-lr"
PKG_VERSION="deb49d80d1836e3e737480a326e31a54c46c04ae"
PKG_SHA256="ebdce1e07e839702ef094b9edaac226c8b02abba9224a859ff18e2a28a09483a"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/snes9x2005"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Snes9x 2005 Plus."

PKG_MAKE_OPTS_TARGET="USE_BLARGG_APU=1 platform=armv8-hardfloat-neon"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a snes9x2005_plus_libretro.so ${INSTALL}/usr/lib/libretro
}
