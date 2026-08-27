# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sdltouchtest"
PKG_VERSION="b62dae0d6233869a4c70a9472bc1e93dec391f94"
PKG_SHA256="aac50a5a38f8be042ae9210a235e672c1fb9c90b7fc96af72b9554d3e94c2ef9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/realchonk/sdl2-touch-test"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="SDL2 touchscreen tester"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  sed -i "s|gcc|${CC}|" Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/test ${INSTALL}/usr/bin/sdltouchtest

case ${DEVICE} in
  RK3399|RK35*|SM8250|SM8550)
    mkdir -p ${INSTALL}/usr/config/modules
    cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
    chmod 0755 ${INSTALL}/usr/config/modules/*
    ;;
  esac
}
