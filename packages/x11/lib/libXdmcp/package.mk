# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libXdmcp"
PKG_VERSION="1.1.5"
PKG_LICENSE="OSS"
PKG_SITE="https://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain util-macros libX11"
PKG_LONGDESC="X Display Manager Control Protocol library."

PKG_CONFIGURE_OPTS_TARGET="--enable-malloc0returnsnull --without-xmlto"

post_configure_target() {
  libtool_remove_rpath libtool
}
