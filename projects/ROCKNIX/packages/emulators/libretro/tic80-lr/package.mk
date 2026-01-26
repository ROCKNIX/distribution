# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="tic80-lr"
PKG_VERSION="7020500a6e88f6ee91301933bb77f082a10e10f5"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nesbox/TIC-80"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="TIC-80 is a fantasy computer for making, playing and sharing tiny games."
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DBUILD_DEMO_CARTS=OFF \
                       -DBUILD_EDITORS=OFF \
                       -DBUILD_LIBRETRO=ON \
                       -DBUILD_PLAYER=OFF \
                       -DBUILD_PRO=OFF \
                       -DBUILD_SDL=OFF \
                       -DBUILD_SDLGPU=OFF \
                       -DBUILD_SOKOL=OFF \
                       -DBUILD_STATIC=ON \
                       -DBUILD_TOOLS=OFF \
                       -DBUILD_TOUCH_INPUT=ON \
                       -DBUILD_WITH_ALL=OFF \
                       -DBUILD_WITH_FENNEL=ON \
                       -DBUILD_WITH_JANET=OFF \
                       -DBUILD_WITH_LUA=ON \
                       -DBUILD_WITH_MRUBY=OFF \
                       -DBUILD_WITH_POCKETPY=OFF \
                       -DBUILD_WITH_QUICKJS=OFF \
                       -DBUILD_WITH_SCHEME=OFF \
                       -DBUILD_WITH_SQUIRREL=OFF \
                       -DBUILD_WITH_WASM=OFF \
                       -DBUILD_WITH_WREN=ON \
                       -DBUILD_WITH_ZLIB=ON \
                       -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/tic80_libretro.so ${INSTALL}/usr/lib/libretro/tic80_libretro.so
}
