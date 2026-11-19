# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gambatte-lr"
PKG_VERSION="77f2567d718b8973d02caa2daa8dce4953faf811"
PKG_SHA256="45e63bc79390093b78de025172ea289ded139f4ecf1e8072242f34d7dd540338"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/gambatte-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="libretro implementation of libgambatte"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a gambatte_libretro.so ${INSTALL}/usr/lib/libretro
}
