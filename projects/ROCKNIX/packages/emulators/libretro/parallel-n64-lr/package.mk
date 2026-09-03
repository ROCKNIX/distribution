# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="parallel-n64-lr"
PKG_VERSION="f8605345e13c018a30c8f4ed03c05d8fc8f70be8"
PKG_LICENSE="GPL-2.0-or-later"
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

if [ "${VULKAN_SUPPORT}" = "yes" ] && [ ${DEVICE} = "AMD64" ]; then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_MAKE_OPTS_TARGET+=" HAVE_PARALLEL=1"
fi

PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"

post_unpackt() {
  if [ "${ARCH}" = "x86_64" ]; then
    grep -rl '\bfsqrt\b' "${PKG_BUILD}/mupen64plus-core/src/r4300/hacktarux_dynarec/" \
      | xargs sed -i 's/\bfsqrt\b/dynarec_fsqrt/g'
  fi
}

pre_configure_target() {
  if [ "${ARCH}" = "aarch64" ]; then
    # This is only needed for armv8.2-a targets where we don't use this flag
    # as it prohibits the use of LSE-instructions, this is a package bug most likely
    export CFLAGS="${CFLAGS} -mno-outline-atomics -std=gnu17"
    export CXXFLAGS="${CXXFLAGS} -mno-outline-atomics"
  elif [ "${ARCH}" = "x86_64" ]; then
    export CFLAGS="${CFLAGS} -std=gnu17"
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a parallel_n64_libretro.so ${INSTALL}/usr/lib/libretro

  mkdir -p ${INSTALL}/usr/config/retroarch
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch
}

