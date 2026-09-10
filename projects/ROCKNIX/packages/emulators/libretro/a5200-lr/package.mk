# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="a5200-lr"
PKG_VERSION="40c6f2f1ad4a3145b328d5baaf010fae6c7e752b"
PKG_SHA256="1b1c382028a188f58f3e1cb7e0f62c926c754824659612703647ce81b9fd4d9e"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/a5200"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Atari 5200 libretro core"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a a5200_libretro.so ${INSTALL}/usr/lib/libretro
}
