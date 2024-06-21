# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="cairomm"
PKG_VERSION="2.4"
PKG_SHA256="YOUR_SHA256_HERE" # Replace with actual SHA256 hash
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.cairographics.org/cairomm/"
PKG_URL="https://www.cairographics.org/releases/cairomm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="cairomm is the official C++ interface for Cairo."

PKG_MESON_OPTS_TARGET="-Dbuild-tests=false"
