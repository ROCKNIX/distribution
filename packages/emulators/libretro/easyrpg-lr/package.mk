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

PKG_NAME="easyrpg-lr"
PKG_VERSION="6ba2f54ed4e2c12b5bd73fc326600a67cf595dde"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/easyrpg/player"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="0-8-0-stable"
PKG_DEPENDS_TARGET="toolchain zlib libfmt liblcf icu pixman libspeexdsp mpg123 libsndfile libvorbis opusfile wildmidi libxmp-lite fluidsynth harfbuzz libpng retroarch"
PKG_LONGDESC="An unofficial libretro port of the EasyRPG/Player."
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="+pic"


PKG_CMAKE_OPTS_TARGET="-DPLAYER_TARGET_PLATFORM=libretro \
                       -DBUILD_SHARED_LIBS=ON \
                       -DCMAKE_BUILD_TYPE=Release"

pre_make_target() {
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/easyrpg_libretro.so ${INSTALL}/usr/lib/libretro/

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/easyrpg.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/easyrpg.sh
}
