# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fake08-lr"
PKG_VERSION="814991a2571ad3970e386cef48f3b148aa1c27b9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/jtothebell/fake-08"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Pico-8 player/emulator for console homebrew"

PKG_MAKE_OPTS_TARGET="-C platform/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platform/libretro/fake08_libretro.{so,info} ${INSTALL}/usr/lib/libretro
}
