# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-lr"
PKG_VERSION="ab8134ac90a567581df6de4fc427dd67bfad1b17"
PKG_SHA256="98e197cdcac64c0e08eda91a6d63b637c3f151066bede25766e62bc1a59552a0"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host"
PKG_LONGDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_BUILD_FLAGS="-lto"
PKG_PATCH_DIRS+=" ${DEVICE}"

PKG_MAKE_OPTS_TARGET="OS_LINUX=1 platform=${DEVICE}"

if [ "${OPENGL}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
  PKG_MAKE_OPTS_TARGET+=" GLES=0 GL_LIB=\"-lGL\""
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" GLES=1 GL_LIB=\"-lGLESv2\""
fi

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

pre_configure_target() {
  export CFLAGS="${CFLAGS} -fcommon -Wno-error=incompatible-pointer-types -std=gnu17"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mupen64plus_libretro.so ${INSTALL}/usr/lib/libretro
}
