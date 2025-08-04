# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pygobject"
PKG_VERSION="3.52.3"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.pygtk.org/"
PKG_URL="http://ftp.gnome.org/pub/GNOME/sources/pygobject/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 glib libffi pgi"
PKG_NEED_UNPACK="$(get_pkg_directory glib) $(get_build_dir glib)"
PKG_LONGDESC="A convenient wrapper for the GObject+ library for use in Python programs."
PKG_TOOLCHAIN="meson"

pre_configure_target() {
  PKG_CONFIG_PATH="${SYSROOT_PREFIX}/usr/lib/pkgconfig"

  PKG_MESON_OPTS_TARGET=" \
                         -Dpython=${TOOLCHAIN}/bin/${PKG_PYTHON_VERSION} \
                         -Dpycairo=disabled \
                         -Dtests=false"
}

post_makeinstall_target() {
  python_remove_source

  rm -rf ${INSTALL}/usr/bin
  rm -rf ${INSTALL}/usr/share/pygobject
}
