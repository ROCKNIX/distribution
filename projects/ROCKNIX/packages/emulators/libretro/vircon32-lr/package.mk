# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vircon32-lr"
PKG_VERSION="3a1b4ae3fb75c1216fab9cc8715e9a122c461a3a"
PKG_SHA256="38afe3e43949ab45ee2afae22c76260cac5473016969a421c0eee7d7b2739619"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/vircon32/vircon32-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES}"
PKG_LONGDESC="Vircon32 32-bit Virtual Console"
PKG_TOOLCHAIN="cmake-make"

PKG_CMAKE_OPTS_TARGET="-DPLATFORM=EMUELEC \
                       -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                       -DCMAKE_RULE_MESSAGES=OFF \
                       -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"

if [ "${PREFER_GLES}" = "yes" ]; then
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_OPENGLES2=1"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a vircon32_libretro.so ${INSTALL}/usr/lib/libretro
}
