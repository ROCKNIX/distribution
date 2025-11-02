# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libXft"
PKG_VERSION="2.3.8"
PKG_SHA256="5e8c3c4bc2d4c0a40aef6b4b38ed2fb74301640da29f6528154b5009b1c6dd49"
PKG_LICENSE="OSS"
PKG_SITE="https://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/lib/libXft-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain fontconfig freetype libXrender util-macros xorgproto"
PKG_LONGDESC="X FreeType library."
PKG_BUILD_FLAGS="+pic -sysroot"

PKG_CONFIGURE_OPTS_TARGET="--disable-static \
                           --enable-shared"
