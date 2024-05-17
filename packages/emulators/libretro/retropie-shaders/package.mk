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

PKG_NAME="retropie-shaders"
PKG_VERSION="015fe2aaad5f4a219c8fd85b9a4fd71bc4f1f731"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/RetroPie/common-shaders"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="rpi"
PKG_DEPENDS_TARGET="toolchain glsl-shaders"
PKG_LONGDESC="Libretro common shaders from retropie"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  if [ ! -d "${INSTALL}/usr/share/common-shaders" ]
  then
    mkdir -p ${INSTALL}/usr/share/common-shaders
  fi
  rsync -a ${BUILD}/${PKG_NAME}-${PKG_VERSION}/* ${INSTALL}/usr/share/common-shaders/
  rm -f ${INSTALL}/usr/share/common-shaders/{Makefile,configure}
}
