# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fceumm-lr"
PKG_VERSION="ac0d00a7fc01166f84c7bac01d1084ebfd2b865e"
PKG_SHA256="364affeeea3d91ab8de4ef2a333cb0ca4d7d8e8992e94366a270b32e309485ca"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-fceumm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Port of FCEUmm / FCEUX to Libretro."

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a fceumm_libretro.so ${INSTALL}/usr/lib/libretro
}
