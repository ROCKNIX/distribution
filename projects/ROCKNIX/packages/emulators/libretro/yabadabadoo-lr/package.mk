# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="yabadabadoo-lr"
PKG_VERSION="59703097c1fa607d1ab524902264fd70fab0b368"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/ProRapSuperstarOriginalMaster/Yabadabadoo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Fork of port of YabaSanshiro to libretro."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

post_unpack() {
  sed -i 's/\-O[23]/-Ofast -ffast-math/' ${PKG_BUILD}/yabause/src/libretro/Makefile
}

pre_configure_target() {
  # no-outline-atomics is only needed for armv8.2-a targets where we don't use this flag
  # as it prohibits the use of LSE-instructions, this is a package bug most likely
  export CFLAGS="${CFLAGS} -flto -fipa-pta -Wno-error=implicit-int -Wno-error=incompatible-pointer-types"
  export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta"
  export LDFLAGS="${CXXFLAGS} -flto -fipa-pta"
  case ${ARCH} in
    aarch64)
      export CFLAGS="${CFLAGS} -mno-outline-atomics"
      export CXXFLAGS="${CXXFLAGS} -mno-outline-atomics"
      PKG_MAKE_OPTS_TARGET+=" platform=unix-${ARCH}"
      ;;
    arm)
      PKG_MAKE_OPTS_TARGET+=" platform=miyoomini"
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  if [ "${ARCH}" = "aarch64" ]; then
    cp -a ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/yabadabadoo-*/usr/lib/libretro/yabadabadoo_libretro.so ${INSTALL}/usr/lib/libretro
  else
    cp -a yabause/src/libretro/yabadabadoo_libretro.so ${INSTALL}/usr/lib/libretro
  fi
}
