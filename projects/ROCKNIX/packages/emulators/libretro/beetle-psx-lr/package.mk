# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="beetle-psx-lr"
PKG_VERSION="ef51860dbd71ad6b7ce67115d4780c2ee321d968"
PKG_SHA256="e50d45fa48e9f0971fe35c810896137a5ff9944e0c199d8f252403ecf959da08"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/beetle-psx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Fork of Mednafen PSX"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

PKG_MAKE_OPTS_TARGET+=" LINK_STATIC_LIBCPLUSPLUS=0"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mednafen_psx_libretro.so ${INSTALL}/usr/lib/libretro/beetle_psx_libretro.so
}
