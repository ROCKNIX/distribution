# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="parallel-n64-lr"
PKG_VERSION="1b57f9199b1f8a4510f7f89f14afa9cabf9b3bdd"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/parallel-n64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain core-info"
PKG_LONGDESC="Optimized/rewritten Nintendo 64 emulator made specifically for Libretro. Originally based on Mupen64 Plus."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_MAKE_OPTS_TARGET+=" HAVE_PARALLEL=1"
fi

case ${DEVICE} in
  RK3*|S922X*)
    PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"
  ;;
  AMD64)
    PKG_MAKE_OPTS_TARGET+=" HAVE_PARALLEL_RSP=1"
esac

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp parallel_n64_libretro.so ${INSTALL}/usr/lib/libretro/

  mkdir -p ${INSTALL}/usr/config/retroarch
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch/
}

