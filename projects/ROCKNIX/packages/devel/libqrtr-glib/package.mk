# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libqrtr-glib"
PKG_VERSION="1689f8b96509314d569f06a05e986a887d6d6ce5"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://github.com/linux-mobile-broadband/libqrtr-glib"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib"
PKG_DEPENDS_HOST="toolchain:host"
PKG_LONGDESC="libqrtr-glib is a glib-based library to use and manage the QRTR (Qualcomm IPC Router) bus."
PKG_TOOLCHAIN="meson"

pre_configure_target() {
  PKG_MESON_OPTS_TARGET+=" -Dintrospection=false"
}