# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vircon32-lr"
PKG_VERSION="9a44a83e5aaa82be7f1a127eb0c9ec0b287b58fa"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/vircon32/vircon32-libretro"
PKG_URL="https://github.com/vircon32/vircon32-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES}"
PKG_LONGDESC="Vircon32 32-bit Virtual Console"
PKG_TOOLCHAIN="cmake-make"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DENABLE_OPENGLES2=1 \
                         -DPLATFORM=EMUELEC \
                         -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                         -DCMAKE_BUILD_TYPE=Release \
                         -DCMAKE_RULE_MESSAGES=OFF \
                         -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -f vircon32_libretro.so ${INSTALL}/usr/lib/libretro
}
