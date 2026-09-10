# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sameduck-lr"
PKG_VERSION="5619abdb01cee6bedb47599cdb5532c318443b52"
PKG_SHA256="101bd2876c0b6c63abc91b3971fa1c203c955d4a86a5c54ce6172ee5ab729456"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/LIJI32/SameBoy"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Mega Duck/Cougar Boy emulator written in C"

PKG_MAKE_OPTS_TARGET="-C libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a build/bin/sameduck_libretro.so ${INSTALL}/usr/lib/libretro
}
