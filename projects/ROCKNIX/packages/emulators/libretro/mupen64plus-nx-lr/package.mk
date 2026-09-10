# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mupen64plus-nx-lr"
PKG_VERSION="f275caf4b2bfa1e6d1c51636746ea793f3d80320"
PKG_SHA256="1810b7bbdc4abfdeee8a9f7f99c4a91dab601a228935802317c25a43d7cf9dbb"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro-nx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host"
PKG_LONGDESC="mupen64plus NX"
PKG_BUILD_FLAGS="-lto"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MAKE_OPTS_TARGET+=" GL_LIB=\"-lGL\" GLES3=0"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" GL_LIB=\"-lGLESv2\" GLES3=1"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_MAKE_OPTS_TARGET+=" HAVE_PARALLEL_RSP=1 HAVE_PARALLEL_RDP=1"
fi

post_unpack() {
  for SOURCE in ${PKG_BUILD}/mupen64plus-rsp-paraLLEl/rsp_disasm.cpp ${PKG_BUILD}/mupen64plus-rsp-paraLLEl/rsp_disasm.hpp; do
    sed -i '/include <string>/a #include <cstdint>' ${SOURCE}
  done
  sed -e "s|^GIT_VERSION ?.*$|GIT_VERSION := \" ${PKG_VERSION:0:7}\"|" -i ${PKG_BUILD}/Makefile
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

pre_configure_target() {
  export CFLAGS="${CFLAGS} -DHAVE_UNISTD_H -Wno-error=incompatible-pointer-types"
  if [ "${ARCH}" = "aarch64" ]; then
    # This is only needed for armv8.2-a targets where we don't use this flag
    # as it prohibits the use of LSE-instructions, this is a package bug most likely
    export CXXFLAGS="${CXXFLAGS} -mno-outline-atomics"
  fi

  case ${ARCH} in
    aarch64) PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}" ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mupen64plus_next_libretro.so ${INSTALL}/usr/lib/libretro
}
