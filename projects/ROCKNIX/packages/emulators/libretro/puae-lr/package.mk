# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="puae-lr"
PKG_VERSION="356160901b4563a60d663829a2e1d07a9207671c"
PKG_SHA256="00e9532adaecb6244a5553ccbbae2a0194d9bf80f349217238530930f97289e1"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-uae"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="WIP libretro port of UAE (P-UAE and libco) Expect bugs"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a puae_libretro.so ${INSTALL}/usr/lib/libretro
}
