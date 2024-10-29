################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
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

PKG_NAME="yabasanshiro-lr"
PKG_VERSION="39535a6abcad5abf9f71c8b2a7975f005ee12ed6"
PKG_GIT_CLONE_BRANCH="yabasanshiro"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/yabause"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of YabaSanshiro to libretro."
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

PKG_PATCH_DIRS+="${DEVICE}"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
  if [ "${ARCH}" = "aarch64" ]; then
    # This is only needed for armv8.2-a targets where we don't use this flag
    # as it prohibits the use of LSE-instructions, this is a package bug most likely
    export CFLAGS="${CFLAGS} -flto -fipa-pta -mno-outline-atomics"
    export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta -mno-outline-atomics"
    export LDFLAGS="${CXXFLAGS} -flto -fipa-pta"
  fi
  sed -i 's/\-O[23]/-Ofast -ffast-math/' ${PKG_BUILD}/yabause/src/libretro/Makefile
  case ${DEVICE} in
    RK3*|S922X|SD865)
      PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro platform=rockpro64 HAVE_NEON=0 FORCE_GLES=1"
    ;;
    H700)
      PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro platform=arm64_cortex_a53_gles3 HAVE_NEON=0 FORCE_GLES=1"
    ;;
    AMD64)
      PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro FORCE_GLES=0 USE_X86_DRC=1 FASTMATH=1"
    ;;
    *)
      PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro FORCE_GLES=1"
    ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp yabause/src/libretro/yabasanshiro_libretro.so ${INSTALL}/usr/lib/libretro/
}
