# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="glib-networking"
PKG_VERSION="2.90.0"
PKG_SHA256="83a75e3d9c36b66ee86d3281c2fc997816101968a5126ba322b2acb9a74dd8c0"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://gitlab.gnome.org/GNOME/glib-networking"
PKG_URL="https://download.gnome.org/sources/${PKG_NAME}/${PKG_VERSION%.*}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain glib gnutls"
PKG_LONGDESC="GIO's TLS backend. gnutls being installed is not enough on its own: without this module libsoup reports 'TLS support is not available' and every https:// request fails, which is every provider sign-in there is."

pre_configure_target() {
  # gnutls is already in the image; openssl and libproxy are not wanted here,
  # and the installed tests are build-time noise.
  PKG_MESON_OPTS_TARGET="-Dgnutls=enabled \
                         -Dopenssl=disabled \
                         -Dlibproxy=disabled \
                         -Dgnome_proxy=disabled \
                         -Dinstalled_tests=false"
}
