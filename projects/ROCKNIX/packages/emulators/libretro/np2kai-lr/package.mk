# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="np2kai-lr"
PKG_VERSION="d1a40352e24f943a91966c48211c92e6eb07f3a5"
PKG_SHA256="c82cef301cc926795c2be584f6c61e28dc9aba2fc12084277c6346db1fd5a637"
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
