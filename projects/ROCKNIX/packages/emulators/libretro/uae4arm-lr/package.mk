# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="uae4arm-lr"
PKG_VERSION="276979efa4f862d1f84afeff5a2e794de4744024"
PKG_SHA256="97a793a6624055cb99c83ca0202b0acd9403bab8c9e16f3dff85d0fdccb944ff"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/Chips-fr/uae4arm-rpi"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain flac mpg123"
PKG_LONGDESC="Port of uae4arm for libretro (rpi/android)"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro platform=unix_aarch64"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a uae4arm_libretro.so ${INSTALL}/usr/lib/libretro
}
