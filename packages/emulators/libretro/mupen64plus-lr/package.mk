################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="mupen64plus-lr"
PKG_VERSION="ab8134ac90a567581df6de4fc427dd67bfad1b17"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host"
PKG_LONGDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"
PKG_PATCH_DIRS+=" ${DEVICE}"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_make_target() {
  export CFLAGS="${CFLAGS} -fcommon"
}

pre_configure_target() {
export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"

  case ${DEVICE} in
    RK3*)
      PKG_MAKE_OPTS_TARGET=" platform=${DEVICE}"
      CFLAGS="${CFLAGS} -DLINUX -DEGL_API_FB"
      CPPFLAGS="${CPPFLAGS} -DLINUX -DEGL_API_FB"
    ;;
    SD865)
      PKG_MAKE_OPTS_TARGET=" platform=RK3588"
      CFLAGS="${CFLAGS} -DLINUX -DEGL_API_FB"
      CPPFLAGS="${CPPFLAGS} -DLINUX -DEGL_API_FB"
    ;;
    H700)
      PKG_MAKE_OPTS_TARGET=" platform=RKH700"
      CFLAGS="${CFLAGS} -DLINUX -DEGL_API_FB"
      CPPFLAGS="${CPPFLAGS} -DLINUX -DEGL_API_FB"
    ;;
    *)
      PKG_MAKE_OPTS_TARGET="GLES=0 GLES3=0"
    ;;
  esac
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp mupen64plus_libretro.so ${INSTALL}/usr/lib/libretro/
}
