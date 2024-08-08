# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="sigcpp"
PKG_VERSION="2.10.8"
PKG_SHA256="235a40bec7346c7b82b6a8caae0456353dc06e71f14bc414bcc858af1838719a"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://libsigcplusplus.github.io/libsigcplusplus/"
PKG_URL="https://download.gnome.org/sources/libsigc++/${PKG_VERSION%.*}/libsigc++-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libsigc++ implements a typesafe callback system for standard C++."

PKG_MESON_OPTS_TARGET="-Dbuild-examples=false"
