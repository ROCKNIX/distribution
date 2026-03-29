# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="jansson"
PKG_VERSION="2.15.0"
PKG_SHA256="a7eac7765000373165f9373eb748be039c10b2efc00be9af3467ec92357d8954"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/akheron/jansson"
PKG_URL="https://github.com/akheron/jansson/releases/download/v${PKG_VERSION}/jansson-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Jansson is a C library for encoding, decoding and manipulating JSON data"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DJANSSON_BUILD_DOCS=OFF \
                       -DJANSSON_BUILD_SHARED_LIBS=ON \
                       -DJANSSON_EXAMPLES=OFF \
                       -DJANSSON_WITHOUT_TESTS=ON"
