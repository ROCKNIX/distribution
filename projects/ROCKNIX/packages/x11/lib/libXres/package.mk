# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libXres"
PKG_VERSION="1.2.2"
PKG_SHA256="9a7446f3484b9b7538ac5ee30d2c1ce9e5b7fbbaf1440e02f6cca186a1fa745f"
PKG_LICENSE="MIT"
PKG_SITE="https://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain util-macros libX11 libXext"
PKG_LONGDESC="X11 library for the X Resource Extension (client resource ID listing)."
PKG_BUILD_FLAGS="+pic"

# Cross-compile: do not run the malloc(0) runtime probe (same as other libX* packages).
PKG_CONFIGURE_OPTS_TARGET="--enable-malloc0returnsnull"

post_configure_target() {
  libtool_remove_rpath libtool
}
