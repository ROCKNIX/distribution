# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fbalpha2019-lr"
PKG_VERSION="0581797db6fdffd826086b053ced4b6b29bb6678"
PKG_SHA256="96812000a349e413d63bc5ef04ab7a330bb0b4194047c048ed6ec549b8274936"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/fbalpha"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of Final Burn Alpha to Libretro (v0.2.97.44)."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_DIR}/fbalpha2019_libretro.info ${INSTALL}/usr/lib/libretro
    cp -a fbalpha_libretro.so ${INSTALL}/usr/lib/libretro/fbalpha2019_libretro.so
}
