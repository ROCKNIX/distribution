# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="lynx"
PKG_VERSION="2.9.2"
PKG_LICENSE="LGPL"
PKG_SITE="https://invisible-island.net"
PKG_URL="${PKG_SITE}/archives/lynx/tarballs/${PKG_NAME}${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ncurses slang gnutls"
PKG_LONGDESC="A curses based web browser."

PKG_CONFIGURE_OPTS_TARGET+=" --with-gnutls --with-ssl"
