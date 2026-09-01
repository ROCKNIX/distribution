# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vecx-lr"
PKG_VERSION="8f671cc9d737f2890c3ce19e177e2984dcae121f"
PKG_SHA256="cd59fe10619be54c60bb6feb2f48c607291f38bd9638b78ee975081d80450065"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/libretro-vecx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro adaptation of vecx"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro HAS_GPU=1 HAS_GLES=1"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a vecx_libretro.so ${INSTALL}/usr/lib/libretro/vecx_libretro.so
}
