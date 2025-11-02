# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libXaw"
PKG_VERSION="1.0.14"
PKG_LICENSE="MIT"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain xorgproto libXt libXmu libX11 libXpm"
PKG_LONGDESC="Athena libary"
PKG_BUILD_FLAGS="+pic"

pre_configure_target() {
  PKG_CONFIGURE_OPTS_TARGET="--disable-static --enable-shared --enable-xthreads"
}
