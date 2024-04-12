################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2020      351ELEC team (https://github.com/fewtarius/351ELEC)
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

PKG_NAME="beetle-supafaust-lr"
PKG_VERSION="6b639c98372d1c9bac885c55d772c812d2a9d525"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/supafaust"
PKG_URL="${PKG_SITE}.git"
#PKG_GIT_CLONE_BRANCH="hd"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Super Nintendo (Super Famicom) emulator"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/mednafen_supafaust_libretro.so ${INSTALL}/usr/lib/libretro/beetle_supafaust_libretro.so

  mkdir -p ${INSTALL}/usr/config/retroarch
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/retroarch/
}
