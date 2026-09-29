# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libtasn1"
PKG_VERSION="4.21.0"
PKG_SHA256="1d8a444a223cc5464240777346e125de51d8e6abf0b8bac742ac84609167dc87"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gnu.org/software/libtasn1/"
PKG_URL="https://ftp.gnu.org/gnu/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASN.1 parser, needed by WebKit for certificate handling."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-doc \
                           --disable-gtk-doc \
                           --disable-static \
                           --enable-shared"
