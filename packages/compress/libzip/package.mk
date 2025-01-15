# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libzip"
PKG_VERSION="1.11.1"
PKG_LICENSE="GPL"
PKG_SITE="https://libzip.org/download"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain zlib gnutls openssl"
PKG_LONGDESC="A C library for reading, creating, and modifying zip archives."
