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

PKG_MAKE_OPTS_TARGET+=" -C yabause/src/libretro"
if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=0"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1"
fi

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"
  sed -i 's/\-O[23]/-Ofast -ffast-math/' ${PKG_BUILD}/yabause/src/libretro/Makefile

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
  cp yabause/src/libretro/yabasanshiro_libretro.so ${INSTALL}/usr/lib/libretro/
}
