# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mojozork-lr"
PKG_VERSION="f94c3104aa18036d9ed5f0243814483f82e486cb"
PKG_SHA256="947f26dc4be2c4413b2f70e3b31c23ad1ea84eff8fa331d89619c14acea56f9c"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/icculus/mojozork"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain sqlite SDL3"
PKG_LONGDESC="A simple Z-Machine implementation in a single C file"

PKG_CMAKE_OPTS_TARGET="-DMOJOZORK_LIBRETRO=ON \
                       -DMOJOZORK_STANDALONE_DEFAULT=OFF \
                       -DMOJOZORK_MULTIZORK_DEFAULT=OFF \
                       -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mojozork_libretro.so ${INSTALL}/usr/lib/libretro
}
