################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2020 351ELEC team (https://github.com/fewtarius/351ELEC)
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

PKG_NAME="vice-lr"
PKG_VERSION="91d0d4d884acd44b5240dfcdbd8bdc2f0f757dfd"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/vice-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Versatile Commodore 8-bit Emulator version 3.0"
PKG_TOOLCHAIN="make"

make_target() {
  if [ ! -d "built" ]
  then
    mkdir built
  fi
  for EMUTYPE in x128 x64sc x64dtv xscpu64 xplus4 xvic xcbm5x0 xcbm2 xpet x64
  do
    make clean
    make EMUTYPE=${EMUTYPE}
    mv vice_*_libretro.so built
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp built/vice_x128_libretro.so ${INSTALL}/usr/lib/libretro/
  cp built/vice_x64_libretro.so ${INSTALL}/usr/lib/libretro/
  cp built/vice_xplus4_libretro.so ${INSTALL}/usr/lib/libretro/
  cp built/vice_xvic_libretro.so ${INSTALL}/usr/lib/libretro/
  cp built/vice_xpet_libretro.so ${INSTALL}/usr/lib/libretro/
}
