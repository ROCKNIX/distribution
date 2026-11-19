# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vircon32-lr"
PKG_VERSION="8b4ff35efb0f3a4c2599fa85ec0e588713f83182"
PKG_SHA256="b3e59585b778022aba9074652003bc6133404f19003207f07c06c463231e6551"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/vircon32/vircon32-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch ${OPENGLES}"
PKG_LONGDESC="Vircon32 32-bit Virtual Console"
PKG_TOOLCHAIN="cmake-make"

PKG_CMAKE_OPTS_TARGET="-DPLATFORM=EMUELEC \
                       -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                       -DCMAKE_RULE_MESSAGES=OFF \
                       -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"

if [ "${PREFER_GLES}" = "yes" ]; then
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_OPENGLES2=1 -DOPENGL_LIBRARIES=GLESv2"
else
  PKG_DEPENDS_TARGET+=" libglvnd"
  PKG_CMAKE_OPTS_TARGET+=" -DOPENGL_LIBRARIES=GL"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a vircon32_libretro.so ${INSTALL}/usr/lib/libretro
}
