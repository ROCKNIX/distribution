# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="potator-lr"
PKG_VERSION="227c5f6f3ce74d32e9002ce24c1420288559a860"
PKG_SHA256="8ce34084e6eaaa380b4c726d0632c0482393f3d23df2cac11eb6bad6952a8f21"
PKG_LICENSE="Unlicense"
PKG_SITE="https://github.com/libretro/potator"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Watara Supervision Emulator based on Normmatt version."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platform/libretro platform=aarch64"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platform/libretro/potator_libretro.so ${INSTALL}/usr/lib/libretro
}
