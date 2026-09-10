# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="plutosvg"
PKG_VERSION="0.0.7"
PKG_SHA256="78561b571ac224030cdc450ca2986b4de915c2ba7616004a6d71a379bffd15f3"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/sammycage/plutosvg"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Tiny SVG rendering library in C"
PKG_DEPENDS_TARGET="toolchain freetype plutovg"
PKG_TOOLCHAIN="cmake"

PKG_BUILD_FLAGS="+pic"
PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                        -DBUILD_SHARED_LIBS=ON \
                        -DINSTALL_DOCS=OFF"
