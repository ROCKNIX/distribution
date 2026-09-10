# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="bsnes2014-balanced-lr"
PKG_VERSION="1a6b3caf187605e53fa9970996bcfa49b8c90ce3"
PKG_SHA256="ee14b173cd509093edd845de092a36becfe22dde93f50583531be87b282e2258"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/bsnes2014"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro fork of bsnes. Built for balance between accuracy and porformance."

PKG_MAKE_OPTS_TARGET="PROFILE=balanced"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a bsnes2014_balanced_libretro.so ${INSTALL}/usr/lib/libretro
}
