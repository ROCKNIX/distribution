# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mu-lr"
PKG_VERSION="f9d34a0006440aef8dca0db2a0d896438fcab2cb"
PKG_SHA256="595b18df6da9b4dc3750d95e0597ad4952e70a79d748b5e1cf3865384ff1d17c"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/Mu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="An emulator for the Palm m515 OS ported to libretro."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C ../libretroBuildSystem"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../libretroBuildSystem/mu_libretro.so ${INSTALL}/usr/lib/libretro
}
