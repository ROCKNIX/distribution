# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="qrencode"
PKG_VERSION="4.1.1"
PKG_SHA256="5385bc1b8c2f20f3b91d258bf8ccc8cf62023935df2d2676b5b67049f31a049c"
PKG_LICENSE="LGPL-2.1"
PKG_SITE="https://fukuchi.org/works/qrencode/"
PKG_URL="https://github.com/fukuchi/libqrencode/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpng"
PKG_LONGDESC="libqrencode with the qrencode CLI for generating QR codes (ANSI terminal output)."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DWITH_TOOLS=YES \
                       -DWITHOUT_PNG=OFF \
                       -DBUILD_SHARED_LIBS=ON"
