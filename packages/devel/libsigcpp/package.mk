# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="libsigcpp"
PKG_VERSION="3.4.0"
PKG_SHA256="445d889079041b41b368ee3b923b7c71ae10a54da03bc746f2d0723e28ba2291"
PKG_LICENSE="LGPL"
PKG_SITE="https://libsigcplusplus.github.io/libsigcplusplus/"
PKG_URL="https://github.com/libsigcplusplus/libsigcplusplus/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libsigc++ implements a typesafe callback system for standard C++."

PKG_MESON_OPTS_TARGET="-Dbuild-examples=false \
                       -Dvalidation=false"
