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

PKG_NAME="mgba-lr"
PKG_VERSION="b2564482c86378581a7a43ef4e254b2a75167bc7"
PKG_LICENSE="MPLv2.0"
PKG_SITE="https://github.com/libretro/mgba"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="mGBA Game Boy Advance Emulator"
PKG_PATCH_DIRS+="${DEVICE}"

PKG_TOOLCHAIN="make"
PKG_USE_CMAKE="no"

make_target() {
  cd ${PKG_BUILD}
  case ${ARCH} in
    arm)
      make -f Makefile.libretro platform=unix-armv HAVE_NEON=1
    ;;
    aarch64)
      make -f Makefile.libretro platform=goadvance
    ;;
    *)
      make -f Makefile.libretro
    ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp mgba_libretro.so ${INSTALL}/usr/lib/libretro/
}
