# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gst-plugins-base"
PKG_VERSION="$(get_pkg_version gstreamer)"
PKG_LICENSE="GPL-2.1-or-later"
PKG_SITE="https://gstreamer.freedesktop.org/modules/gst-plugins-base.html"
PKG_URL="https://gstreamer.freedesktop.org/src/gst-plugins-base/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain gstreamer"
PKG_LONGDESC="Base GStreamer plugins and helper libraries"
PKG_BUILD_FLAGS="-gold"

pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Dexamples=disabled \
                         -Dtests=disabled \
                         -Dgobject-cast-checks=disabled \
                         -Dpackage-name=gst-plugins-base \
                         -Dpackage-origin=rocknix.org \
                         -Ddoc=disabled \
                         -Dnls=disabled"

  # Fix missing dispmanx
  case ${DEVICE} in
    RK3*|S922X)
      PKG_MESON_OPTS_TARGET+=" -Dgl-graphene=disabled"
    ;;
  esac
}

post_makeinstall_target() {
  # clean up
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/share
}
