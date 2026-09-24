# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="miniz"
PKG_VERSION="3.1.1"
PKG_SHA256="8bb29c7bd6f22356e5583e794bed4a0b3e6dfcbcadb49974fc9270ccca1e5557"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/richgel999/miniz"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Single C source file zlib-replacement library"
# Meson does not install the miniz CMake package the consumers look for
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="+pic"

PKG_CMAKE_OPTS_TARGET="-DBUILD_EXAMPLES=OFF \
                       -DBUILD_TESTS=OFF \
                       -DBUILD_FUZZERS=OFF \
                       -DINSTALL_PROJECT=ON"
