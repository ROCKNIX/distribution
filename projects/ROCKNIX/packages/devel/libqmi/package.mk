# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libqmi"
PKG_VERSION="0536681a4ab46021e13c1cf8fa94b0b13b93b0c6"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://github.com/linux-mobile-broadband/libqmi"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libgudev glib libqrtr-glib ninja:host"
PKG_LONGDESC="libqmi is a glib-based library for talking to WWAN modems and devices which speak the Qualcomm MSM Interface (QMI) protocol."
PKG_TOOLCHAIN="meson"

pre_configure_target() {
  PKG_MESON_OPTS_TARGET+=" -Dbash_completion=false \
                           -Dmbim_qmux=false \
                           -Dman=false \
                           -Dintrospection=false"
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/include
}