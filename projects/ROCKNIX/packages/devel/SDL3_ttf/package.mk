# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL3_ttf"
PKG_VERSION="3.2.2"
PKG_SHA256="63547d58d0185c833213885b635a2c0548201cc8f301e6587c0be1a67e1e045d"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libsdl.org/"
PKG_URL="https://github.com/libsdl-org/SDL_ttf/releases/download/release-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL3 freetype"
PKG_LONGDESC="This is a sample library which allows you to use TrueType fonts in your SDL applications"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DFREETYPE_INCLUDE_DIRS=${SYSROOT_PREFIX}/usr"
