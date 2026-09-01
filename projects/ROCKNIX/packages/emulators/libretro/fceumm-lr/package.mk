# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fceumm-lr"
PKG_VERSION="236ccdfc911e84c60fea6b9d0699c2d440a8de14"
PKG_SHA256="dd002cde9b5271979e0394bb9e696bd37e149ced473ff1e3629cc7fed502381f"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-fceumm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of FCEUmm / FCEUX to Libretro."

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a fceumm_libretro.so ${INSTALL}/usr/lib/libretro
}
