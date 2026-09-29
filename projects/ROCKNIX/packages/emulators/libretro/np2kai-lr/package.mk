# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="np2kai-lr"
PKG_VERSION="5939e0c6d5985c4c08fc70f289a83290e5d3e6f7"
PKG_SHA256="8080b89ac0f9a63c9430fd60b3c129f63c1dbbe38b41f086a1df802dd2b4b53b"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/AZO234/NP2kai"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Neko Project II kai"
PKG_TOOLCHAIN="make"

VERSION="${PKG_VERSION:0:7}"

PKG_MAKE_OPTS_TARGET="-C ../sdl NP2KAI_VERSION=${VERSION} NP2KAI_HASH=${VERSION}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../sdl/np2kai_libretro.so ${INSTALL}/usr/lib/libretro
}
