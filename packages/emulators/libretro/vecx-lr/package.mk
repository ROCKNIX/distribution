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

PKG_NAME="vecx-lr"
PKG_VERSION="0e48a8903bd9cc359da3f7db783f83e22722c0cf"
PKG_LICENSE="GPLv2|LGPLv2.1"
PKG_SITE="https://github.com/libretro/libretro-vecx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libretro adaptation of vecx"

PKG_TOOLCHAIN="make"

make_target() {
  make -f Makefile.libretro HAS_GPU=1 HAS_GLES=1
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp vecx_libretro.so ${INSTALL}/usr/lib/libretro/vecx_libretro.so
}
