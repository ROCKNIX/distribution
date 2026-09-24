# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cxxopts"
PKG_VERSION="3.3.1"
PKG_SHA256="3bfc70542c521d4b55a46429d808178916a579b28d048bd8c727ee76c39e2072"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/jarro2783/cxxopts"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A header-only C++ command line option parser"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCXXOPTS_BUILD_EXAMPLES=OFF \
                       -DCXXOPTS_BUILD_TESTS=OFF \
                       -DCXXOPTS_ENABLE_INSTALL=ON"
