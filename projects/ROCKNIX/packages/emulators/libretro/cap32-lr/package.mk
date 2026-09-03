# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cap32-lr"
PKG_VERSION="4abfb8be233bec630f369379fb6c1d92d31f1c7d"
PKG_SHA256="45c92ca63aaf2d12c81b9c1de28b0a301b1c37c5b5de7fcfd44fe303c45662b9"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-cap32"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="caprice32 4.2.0 libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a cap32_libretro.so ${INSTALL}/usr/lib/libretro
}
