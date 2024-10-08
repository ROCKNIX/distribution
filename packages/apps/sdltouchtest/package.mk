# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sdltouchtest"
PKG_VERSION="b62dae0d6233869a4c70a9472bc1e93dec391f94"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/realchonk/sdl2-touch-test"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="SDL2 touchscreen tester"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  sed -i "s|gcc|${CC}|" Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/test ${INSTALL}/usr/bin/sdltouchtest
}
