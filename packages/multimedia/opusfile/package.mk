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

PKG_NAME="opusfile"
PKG_VERSION="9d718345ce03b2fad5d7d28e0bcd1cc69ab2b166"
PKG_SITE="https://github.com/xiph/opusfile"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain opus openssl"
PKG_LONGDESC="Stand-alone decoder library for .opus streams"
PKG_TOOLCHAIN="autotools"

#pre_configure_target() {
#  cd ${BUILD_DIR}
#  ./autogen.sh
#}
