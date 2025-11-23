# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="tic80-lr"
PKG_VERSION="21aa81a1ac263d584bb2656d283fa149685bb82d"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nesbox/TIC-80"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="TIC-80 is a fantasy computer for making, playing and sharing tiny games."
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DBUILD_PLAYER=ON \
                       -DBUILD_SOKOL=OFF \
                       -DBUILD_SDL=OFF \
                       -DBUILD_TOUCH_INPUT=ON \
                       -DBUILD_DEMO_CARTS=OFF \
                       -DBUILD_LIBRETRO=ON \
                       -DBUILD_WITH_MRUBY=OFF \
                       -DBUILD_WITH_JANET=OFF \
                       -DCMAKE_BUILD_TYPE=Release \
                       -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/tic80_libretro.so ${INSTALL}/usr/lib/libretro/tic80_libretro.so
}
