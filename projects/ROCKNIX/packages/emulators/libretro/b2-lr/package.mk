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

PKG_NAME="b2-lr"
PKG_VERSION="ffcfcddc5ba05a97e04372672879bc25284ff653"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/zoltanvb/b2-libretro"
PKG_URL="https://github.com/zoltanvb/b2-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Adaptation of Tom Seddon's b2 emulator for BBC Micro"

PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}/src/libretro
  make -j$(getconf _NPROCESSORS_ONLN) clean
  make -j$(getconf _NPROCESSORS_ONLN)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp b2_libretro.so ${INSTALL}/usr/lib/libretro/
}
