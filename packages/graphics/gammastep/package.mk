# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gammastep"
PKG_VERSION="master"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.com/chinstrap/gammastep"
PKG_URL="https://gitlab.com/chinstrap/gammastep/-/archive/master/gammastep-{PKG_VERSION}.tar.gz"
#https://gitlab.com/chinstrap/gammastep/-/archive/master/gammastep-master.tar.gz
PKG_DEPENDS_TARGET="toolchain libdrm libxcb xrandr wayland"
PKG_LONGDESC="Adjust the color temperature of your screen according to your surroundings. This may help your eyes hurt less if you are working in front of the screen at night."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-gui \
			   --disable-geoclue2 \ 
			   --with-systemduserunitdir=no \
		           --disable-nls"

post_makeinstall_target() {
:
}
