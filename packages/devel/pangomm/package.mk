# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="pangomm"
PKG_VERSION="2.46.4"
PKG_SHA256="b92016661526424de4b9377f1512f59781f41fb16c9c0267d6133ba1cd68db22"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/pangomm/${PKG_VERSION%.*}/pangomm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain cairomm glibmm"
PKG_LONGDESC="pangomm is the official C++ interface for Pango."

PKG_MESON_OPTS_TARGET="-Dbuild-documentation=false -Dmaintainer-mode=false -Dmsvc14x-parallel-installable=false"