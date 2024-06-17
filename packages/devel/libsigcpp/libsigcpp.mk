# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="libsigcpp"
PKG_VERSION="3.4.0"
PKG_SHA256="1f5874358ed17e2c5d8aa7a2b19d61172caba2e4e8e383eccb8f0d7d87550a09"
PKG_LICENSE="LGPL"
PKG_SITE="https://libsigcplusplus.github.io/libsigcplusplus/"
PKG_URL="https://github.com/libsigcplusplus/libsigcplusplus/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libsigc++ implements a typesafe callback system for standard C++."

PKG_MESON_OPTS_TARGET="-Dbuild-examples=false \
                       -Dvalidation=false"
