# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="socat"
PKG_VERSION="1.8.1.1"
PKG_LICENSE="GPLv2+"
PKG_SITE="http://www.dest-unreach.org/socat/download"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A multipurpose relay (SOcket CAT)"
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET+="	--disable-libwrap \
				--disable-readline \
				--enable-termios"

post_configure_target() {
  sed -i \
    -e 's|\$(INSTALL) -m 755 socat-chain.sh|\$(INSTALL) -m 755 $(srcdir)/socat-chain.sh|' \
    -e 's|\$(INSTALL) -m 755 socat-mux.sh|\$(INSTALL) -m 755 $(srcdir)/socat-mux.sh|' \
    -e 's|\$(INSTALL) -m 755 socat-broker.sh|\$(INSTALL) -m 755 $(srcdir)/socat-broker.sh|' \
    Makefile
}
