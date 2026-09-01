# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="yabasanshiro-lr"
PKG_VERSION="39535a6abcad5abf9f71c8b2a7975f005ee12ed6"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/yabause"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of YabaSanshiro to libretro."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=0"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1"
fi

post_unpack() {
  sed -i 's/\-O[23]/-Ofast -ffast-math/' ${PKG_BUILD}/yabause/src/libretro/Makefile
}

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

  case ${ARCH} in
    aarch64)
      PKG_MAKE_OPTS_TARGET+=" platform=rockpro64 HAVE_NEON=0"
      # no-outline-atomics is only needed for armv8.2-a targets where we don't use this flag
      # as it prohibits the use of LSE-instructions, this is a package bug most likely
      export CFLAGS="${CFLAGS} -flto -fipa-pta -mno-outline-atomics"
      export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta -mno-outline-atomics"
      export LDFLAGS="${CXXFLAGS} -flto -fipa-pta"
      ;;
    x86_64)
      PKG_MAKE_OPTS_TARGET+=" USE_X86_DRC=1 FASTMATH=1"
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a yabause/src/libretro/yabasanshiro_libretro.so ${INSTALL}/usr/lib/libretro
}
