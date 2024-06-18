# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="gtkmm"
PKG_VERSION="3.0.1"
PKG_SHA256="ea9a877f382397eb680c5e6c003ebd821f225ef4e370c972505ee2b991d6fb61"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/gtkmm/${PKG_VERSION%.*}/gtkmm-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="gtkmm is the official C++ interface for the popular GUI library GTK."

# No package 'giomm-2.4' found NRWIP
# No package 'pangomm-1.4' found
# No package 'cairomm-1.0' found

PKG_MESON_OPTS_TARGET="-Dbuild-tests=false"
