################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
#      Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)
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

PKG_NAME="dosbox-core-lr"
PKG_VERSION="f2733c99db916044015ca0fcb7cd837e93892c84"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/realnc/dosbox-core"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_GIT_CLONE_BRANCH="libretro"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Upstream port of DOSBox to libretro"
PKG_BUILD_FLAGS="-lto"
PKG_TOOLCHAIN="make"

make_target() {
  #export PKG_CONFIG_DEBUG_SPEW=1
  make -C libretro target=arm64 platform=unix WITH_FAKE_SDL=1 STATIC_LIBCXX=0 \
	WITH_DYNAREC=arm64 WITH_FLUIDSYNTH=0 BUNDLED_AUDIO_CODECS=0 BUNDLED_GLIB=0 \
	BUNDLED_LIBSNDFILE=0 WITH_PINHACK=0 WITH_VOODOO=0 WITH_BASSMIDI=0
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/libretro/dosbox_core_libretro.so ${INSTALL}/usr/lib/libretro
}
