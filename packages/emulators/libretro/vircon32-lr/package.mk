# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="vircon32-lr"
PKG_VERSION="f0a3a3164a16d6fcc0db72399243044963f57a24"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/vircon32/vircon32-libretro"
PKG_URL="${PKG_SITE}.git"
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
