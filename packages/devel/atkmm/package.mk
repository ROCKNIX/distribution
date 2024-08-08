# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="atkmm"
PKG_VERSION="2.28.4"
PKG_SHA256="0a142a8128f83c001efb8014ee463e9a766054ef84686af953135e04d28fdab3"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/atkmm/${PKG_VERSION%.*}/atkmm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain cairomm glibmm"
PKG_LONGDESC="atkmm is the official C++ interface for the ATK accessibility toolkit."

PKG_MESON_OPTS_TARGET="-Dbuild-documentation=false -Dmaintainer-mode=false -Dmsvc14x-parallel-installable=false"