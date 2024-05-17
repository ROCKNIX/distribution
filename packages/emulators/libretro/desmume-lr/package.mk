# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="desmume-lr"
PKG_VERSION="b518fec54b79f2f71a7536715efcdcd7f60638a8"
PKG_LICENSE="GPLv2"
PKG_SITE="https://git.libretro.com/libretro/desmume"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libpcap"
PKG_LONGDESC="DeSmuME - Nintendo DS libretro"
PKG_TOOLCHAIN="make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"

elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_PATCH_DIRS+=" gles"
fi


pre_configure_target() {
  cd ${PKG_BUILD}/desmume/src/frontend/libretro
}

if [ "${ARCH}" = "arm" ]
then
  make_target() {
      make CC=${CC} platform=armv-unix-${TARGET_FLOAT}float-${TARGET_CPU}
  }
elif [ "${ARCH}" = "x86_64" ]
then
  make_target() {
      make CC=${CC} platform=unix
  }
else
  make_target() {
    :
  }
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  if [ "${ARCH}" = "aarch64" ]
  then
    cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/desmume-*/.install_pkg/usr/lib/libretro/desmume_libretro.so ${INSTALL}/usr/lib/libretro/
  else
    cp desmume_libretro.so ${INSTALL}/usr/lib/libretro/
  fi
}
