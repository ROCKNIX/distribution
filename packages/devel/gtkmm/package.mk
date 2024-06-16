# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="gtkmm"
PKG_VERSION="3.24.9"
PKG_SHA256="30d5bfe404571ce566a8e938c8bac17576420eb508f1e257837da63f14ad44ce"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/gtkmm/${PKG_VERSION%.*}/gtkmm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain gtk3 pangomm atkmm"
PKG_LONGDESC="gtkmm is the official C++ interface for the popular GUI library GTK."

PKG_MESON_OPTS_TARGET="-Dbuild-tests=false -Dbuild-demos=false -Dbuild-x11-api=false -Dmaintainer-mode=false -Dmsvc14x-parallel-installable=false"
