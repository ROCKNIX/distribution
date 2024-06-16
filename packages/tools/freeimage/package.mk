# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="freeimage"
PKG_VERSION="3180"
PKG_LICENSE="GPLv3"
PKG_SITE="http://freeimage.sourceforge.net/"
PKG_URL="$SOURCEFORGE_SRC/${PKG_NAME}/FreeImage${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_SOURCE_DIR="FreeImage"
PKG_LONGDESC="FreeImage library"

pre_make_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++11 -fPIC -Wno-implicit-function-declaration"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0 -fPIC -Wno-implicit-function-declaration"
}
