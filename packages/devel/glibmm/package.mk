# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="glibmm"
PKG_VERSION="2.80"
PKG_SHA256="539b0a29e15a96676c4f0594541250566c5ca44da5d4d87a3732fa2d07909e4a"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://www.gtkmm.org/"
PKG_URL="https://download.gnome.org/sources/glibmm/${PKG_VERSION}/glibmm-${PKG_VERSION}.0.tar.xz"
PKG_DEPENDS_TARGET="toolchain glib libsigcpp sigcpp python3-packaging"
PKG_LONGDESC="glibmm is the official C++ interface for the popular cross-platform library Glib."

pre_configure_target() {
  export PYTHONPATH="${SYSROOT_PREFIX}/usr/lib/python3.11/site-packages:${PYTHONPATH}"
  python3 -c "import packaging"
}

makeinstall_target() {  
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
  cp ${PKG_BUILD}/.aarch64-rocknix-linux-gnueabi/gio/giomm-2.68.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
}
