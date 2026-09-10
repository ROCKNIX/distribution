# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vitaquake3-lr"
PKG_VERSION="8ab09d1f54bdd3b69cccf9c648a5d9736701ac63"
PKG_SHA256="9e95144e89617e84a9e9522a80775dd5dfdd904fe9bcac5451bac3a464dafefc"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/vitaquake3"
PKG_URL="https://github.com/libretro/vitaquake3/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Quake III - ioquake3 port for libretro"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a vitaquake3_libretro.so $INSTALL/usr/lib/libretro
}
