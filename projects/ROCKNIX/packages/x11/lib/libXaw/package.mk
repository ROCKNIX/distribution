# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libXaw"
PKG_VERSION="1.0.16"
PKG_SHA256="731d572b54c708f81e197a6afa8016918e2e06dfd3025e066ca642a5b8c39c8f"
PKG_LICENSE="MIT"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain xorgproto libXt libXmu libX11 libXpm"
PKG_LONGDESC="Athena libary"
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--disable-static --enable-shared --enable-xthreads"
