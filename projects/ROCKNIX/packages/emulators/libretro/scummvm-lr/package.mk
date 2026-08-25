# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="scummvm-lr"
PKG_VERSION="292e409938384ac0b3819a336c61fbb71dcbb9c3"
PKG_SHA256="1027995a51a1eb429249c3afb6e6b438897652909a9384a82a539716b1d5182e"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/scummvm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ScummVM with libretro backend."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

PKG_MAKE_OPTS_TARGET="-C ../backends/platform/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../backends/platform/libretro/scummvm_libretro.so ${INSTALL}/usr/lib/libretro
}
