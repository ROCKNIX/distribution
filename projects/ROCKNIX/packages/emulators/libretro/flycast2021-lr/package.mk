# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="flycast2021-lr"
PKG_VERSION="603814c9f73b773c455d9a497f389d2f93a257fd"
PKG_SHA256="8aa94bdd669bab05a10ff03c8a977eccd41a30063271da3f81a7a50b1a72f4ca"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/metallic77/flycast"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast emulator "
PKG_BUILD_FLAGS="-gold"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=0"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_MAKE_OPTS_TARGET+=" HAVE_VULKAN=1"
fi

post_unpack() {
  sed -i 's/define CORE_OPTION_NAME "reicast"/define CORE_OPTION_NAME "flycast2021"/g' ${PKG_BUILD}/core/libretro/libretro_core_option_defines.h
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

PKG_MAKE_OPTS_TARGET+=" ARCH=${TARGET_ARCH} HAVE_OPENMP=0 GIT_VERSION=${PKG_VERSION:0:7} HAVE_LTCG=0"

pre_make_target() {
  export BUILD_SYSROOT=${SYSROOT_PREFIX}
  case ${ARCH} in
    aarch64) PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}" ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a flycast_libretro.so ${INSTALL}/usr/lib/libretro/flycast2021_libretro.so
}
