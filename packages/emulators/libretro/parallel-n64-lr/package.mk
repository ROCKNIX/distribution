# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="parallel-n64-lr"
PKG_VERSION="e372c5e327dcd649e9d840ffc3d88480b6866eda"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/parallel-n64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain core-info"
PKG_LONGDESC="Optimized/rewritten Nintendo 64 emulator made specifically for Libretro. Originally based on Mupen64 Plus."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MAKE_OPTS_TARGET+=" GLES=0 GL_LIB=\"-lGL\""
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" GLES=1 GL_LIB=\"-lGLESv2\""
fi

if [ "${VULKAN_SUPPORT}" = "yes" ] && [ ! ${DEVICE} = "SM8250" ]; then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_MAKE_OPTS_TARGET+=" HAVE_PARALLEL=1"
fi

pre_configure_target() {
  if [ "${ARCH}" = "aarch64" ]; then
    # This is only needed for armv8.2-a targets where we don't use this flag
    # as it prohibits the use of LSE-instructions, this is a package bug most likely
    export CFLAGS="${CFLAGS} -mno-outline-atomics"
    export CXXFLAGS="${CXXFLAGS} -mno-outline-atomics"
    PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp parallel_n64_libretro.so ${INSTALL}/usr/lib/libretro/

  mkdir -p ${INSTALL}/usr/config/retroarch
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch/
}

