# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libXRes"
PKG_VERSION="860f84072e864832d3a94c365241fe619967b63a"
PKG_LICENSE="OSS"
PKG_SITE="https://gitlab.freedesktop.org/xorg/lib/libxres"
PKG_URL="https://gitlab.freedesktop.org/xorg/lib/libxres.git"
PKG_DEPENDS_TARGET="toolchain util-macros libX11"
PKG_LONGDESC="libXRes - X-Resource extension client library"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-malloc0returnsnull --without-xmlto"

post_configure_target() {
  libtool_remove_rpath libtool
}
