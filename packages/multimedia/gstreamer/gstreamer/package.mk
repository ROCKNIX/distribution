# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gstreamer"
PKG_VERSION="1.24.6"
PKG_LICENSE="GPL-2.1-or-later"
PKG_SITE="https://gstreamer.freedesktop.org"
PKG_URL="https://gstreamer.freedesktop.org/src/gstreamer/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain glib glib:host ffmpeg libvorbis-system flac-system"
PKG_LONGDESC="GStreamer open-source multimedia framework core library"

pre_configure_target() {
PKG_MESON_OPTS_TARGET="-Dlibunwind=disabled \
                       -Dexamples=disabled \
                       -Dtests=disabled \
                       -Dnls=disabled \
                       -Dpackage-name=gstreamer \
                       -Dpackage-origin=rocknix.org \
                       -Ddoc=disabled"
}

post_makeinstall_target() {
  # clean up
  safe_remove ${INSTALL}/usr/share
}
