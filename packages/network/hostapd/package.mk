# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="hostapd"
PKG_VERSION="2.11"
PKG_LICENSE="GPL"
PKG_SITE="https://w1.fi/hostapd/"
PKG_URL="https://w1.fi/releases/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain dbus libnl openssl"
PKG_LONGDESC="A user space daemon for access point and authentication servers."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="+lto-parallel"

PKG_MAKE_OPTS_TARGET="-C hostapd V=1 LIBDIR=/usr/lib BINDIR=/usr/bin"
PKG_MAKEINSTALL_OPTS_TARGET="-C hostapd V=1 LIBDIR=/usr/lib BINDIR=/usr/bin"

configure_target() {
  LDFLAGS="${LDFLAGS} -lpthread -lm"

  cp ${PKG_DIR}/config/makefile.config hostapd/.config
}

