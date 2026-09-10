# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pyxel"
PKG_VERSION="2.9.9"
PKG_SHA256="2a8c896dd8854eede7992c22878903333a69b6acfabb874f8aefbdee519c2ca1"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/kitao/pyxel"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}-cp311-abi3-manylinux_2_28_aarch64.whl"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="Pyxel is a retro game engine for Python"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
    unzip -q -o -d ${PKG_BUILD} ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.whl ${PKG_NAME}/*
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}/site-packages/${PKG_NAME}
    cp -a ${PKG_BUILD}/${PKG_NAME}/{*.py,*.so} ${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}/site-packages/${PKG_NAME}
}

