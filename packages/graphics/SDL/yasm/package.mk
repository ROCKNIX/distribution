################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="yasm"
PKG_VERSION="1.3.0"
PKG_SHA256="3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f"
PKG_LICENSE="BSD"
PKG_SITE="http://www.tortall.net/projects/yasm/"
PKG_URL="http://www.tortall.net/projects/yasm/releases/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST=""
PKG_LONGDESC="yasm: A complete rewrite of the NASM assembler"

PKG_USE_CMAKE="no"

PKG_CONFIGURE_OPTS_HOST="--disable-debug \
                         --disable-warnerror \
                         --disable-profiling \
                         --disable-gcov \
                         --disable-python \
                         --disable-python-bindings \
                         --enable-nls \
                         --disable-rpath \
                         --without-dmalloc \
                         --with-gnu-ld \
                         --without-libiconv-prefix \
                         --without-libintl-prefix"
