# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="scummvm-lr"
PKG_VERSION="e0ddc60bfabb1efdf1e135006c8914ca59d0596c"
PKG_SHA256="2f87ca94ce79af39571951f797712e350870c3e56f5b5d288328f377f73d15f9"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/scummvm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="ScummVM with libretro backend."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

PKG_MAKE_OPTS_TARGET="-C ../backends/platform/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../backends/platform/libretro/scummvm_libretro.so ${INSTALL}/usr/lib/libretro
}
