# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="common-shaders"
PKG_VERSION="9c0d839a19651dffc9898da7673574a20fb39415"
PKG_SHA256="746982be0acfe487eef493b6ef0590042488f69a8134b58a705b2f249e1dcc50"
PKG_ARCH="aarch64"
PKG_LICENSE=""
PKG_SITE="https://github.com/libretro/common-shaders"
PKG_URL="https://github.com/libretro/common-shaders/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Libretro common shaders"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/common-shaders
    cp -a ${PKG_BUILD}/* ${INSTALL}/usr/share/common-shaders
    rm -f ${INSTALL}/usr/share/common-shaders/{Makefile,configure}
}
