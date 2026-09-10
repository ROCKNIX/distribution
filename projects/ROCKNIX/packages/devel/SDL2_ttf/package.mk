# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2_ttf"
PKG_VERSION="2.20.2"
PKG_SHA256="9dc71ed93487521b107a2c4a9ca6bf43fb62f6bddd5c26b055e6b91418a22053"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libsdl.org/"
PKG_URL="https://github.com/libsdl-org/SDL_ttf/releases/download/release-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 freetype"
PKG_LONGDESC="This is a sample library which allows you to use TrueType fonts in your SDL applications"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DFREETYPE_INCLUDE_DIRS=${SYSROOT_PREFIX}/usr"
