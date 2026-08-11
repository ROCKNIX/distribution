# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017 Escalade
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="at-spi2-core"
PKG_VERSION="2.61.1"
PKG_SHA256="0f88d443b8e3a4f7c701c4f6625032a989b8a0244cb2bdb3d3bd9872f00506f4"
PKG_LICENSE="OSS"
PKG_SITE="http://www.gnome.org/"
PKG_URL="https://download.gnome.org/sources/at-spi2-core/${PKG_VERSION:0:4}/at-spi2-core-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain atk dbus glib libXtst libXext libXi"
PKG_LONGDESC="Protocol definitions and daemon for D-Bus at-spi."

PKG_MESON_OPTS_TARGET="-Ddocs=false \
                       -Dintrospection=disabled \
                       -Ddbus_daemon=/usr/bin/dbus-daemon"

pre_configure_target() {
  TARGET_LDFLAGS="${TARGET_LDFLAGS} -lXi -lXext"
}
