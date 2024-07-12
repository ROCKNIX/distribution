# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="vitaquake3-lr"
PKG_VERSION="7a633867cf0a35c71701aef6fc9dd9dfab9c33a9"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/vitaquake3"
PKG_URL="https://github.com/libretro/vitaquake3/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Quake III - ioquake3 port for libretro"
PKG_TOOLCHAIN="make"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-implicit-int"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp vitaquake3_libretro.so $INSTALL/usr/lib/libretro/
}
