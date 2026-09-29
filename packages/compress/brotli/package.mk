# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="brotli"
PKG_VERSION="1.2.0"
PKG_SHA256="816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/google/brotli"
PKG_URL="https://github.com/google/brotli/archive/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Brotli compression, required by woff2 to decode web fonts."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=ON \
                       -DBROTLI_DISABLE_TESTS=ON"
