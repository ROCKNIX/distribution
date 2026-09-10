# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-lr"
PKG_VERSION="66b5d2634cd0a79030562811e6e05f5532f800ba"
PKG_SHA256="8fa494f12a8fe7f20a4ab32ac89a1391f079d41a203d02822b8541e71637a22c"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/melonDS"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MelonDS - Nintendo DS emulator for libretro"
PKG_TOOLCHAIN="make"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_make_target() {
  cd ${PKG_BUILD}
  if [ -e "CMakeLists.txt" ]; then
    rm -f CMakeLists.txt
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a melonds_libretro.so ${INSTALL}/usr/lib/libretro
}
