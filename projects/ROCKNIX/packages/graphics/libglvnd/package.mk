# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libglvnd"
PKG_VERSION="1.7.0"
PKG_SHA256="073e7292788d4d3eeb45ea6c7bdcce9bfdb3b3eef8d7dbd47f2f30dce046ef98"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/NVIDIA/libglvnd"
PKG_URL="https://github.com/NVIDIA/libglvnd/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libglvnd is a vendor-neutral dispatch layer for arbitrating OpenGL API calls between multiple vendors."

configure_package() {
  if [ "${DISPLAYSERVER}" = "x11" ] || \
     [ "${DISPLAYSERVER}" = "wl" ]; then
    PKG_DEPENDS_TARGET+=" libX11 libXext xorgproto"
  fi
}

pre_configure_target(){
  if [ "${OPENGL_SUPPORT}" = "yes" ]
  then
    PKG_MESON_OPTS_TARGET+=" -Degl=true -Dglx=enabled -Dheaders=true"
  fi
    
  if [ "${OPENGLES_SUPPORT}" = "yes" ]
  then
    PKG_MESON_OPTS_TARGET+=" -Dgles1=true -Dgles2=true -Dheaders=true"
  else
    PKG_MESON_OPTS_TARGET+=" -Dgles1=false -Dgles2=false"
  fi
}

