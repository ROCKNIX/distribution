# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="pangomm"
PKG_VERSION="2.4"
PKG_SHA256="YOUR_SHA256_HERE" # Replace with actual SHA256 hash
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/pangomm/${PKG_VERSION%.*}/pangomm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="pangomm is the official C++ interface for Pango."

PKG_MESON_OPTS_TARGET="-Dbuild-tests=false"
