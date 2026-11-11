# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vecx-lr"
PKG_VERSION="dccff5402a16d1ea7c112095a8e42632bf149506"
PKG_SHA256="684808db7e9d3a81647e25e8a7e34df3e0f62ed317df578143055c6536d23a32"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-vecx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="libretro adaptation of vecx"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro HAS_GPU=1 HAS_GLES=1"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a vecx_libretro.so ${INSTALL}/usr/lib/libretro/vecx_libretro.so
}
