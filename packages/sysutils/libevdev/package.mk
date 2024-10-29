# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libevdev"
PKG_VERSION="1.13.3"
PKG_LICENSE="MIT"
PKG_SITE="http://www.freedesktop.org/wiki/Software/libevdev/"
PKG_URL="http://www.freedesktop.org/software/libevdev/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libevdev is a wrapper library for evdev devices."
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET=" \
  -Ddefault_library=shared \
  -Ddocumentation=disabled \
  -Dtests=disabled"

# libevdev by default installs header incorrectly, this solves that
pre_configure_target() {
  sed -i -E "s|subdir: 'libevdev-1.0\/|subdir: '|g" ${PKG_BUILD}/meson.build
  sed -i -E "s|subdirs: 'libevdev-1.0',||g" ${PKG_BUILD}/meson.build
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
