# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="glibmm"
PKG_VERSION="2.66.7"
PKG_SHA256="fe02c1e5f5825940d82b56b6ec31a12c06c05c1583cfe62f934d0763e1e542b3"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/glibmm/${PKG_VERSION%.*}/glibmm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain cairomm"
PKG_LONGDESC="glibmm is the official C++ interface for glib."

PKG_MESON_OPTS_TARGET="-Dbuild-examples=false -Dbuild-documentation=false -Dmaintainer-mode=false -Dmsvc14x-parallel-installable=false"