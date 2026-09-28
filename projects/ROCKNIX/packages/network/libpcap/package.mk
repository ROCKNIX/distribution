# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/network-tools-depends/depends/libpcap/package.mk

PKG_BUILD_FLAGS="${PKG_BUILD_FLAGS/-cfg-libs/}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--disable-shared/--disable-static}"

post_makeinstall_target() {
  ln -sfv /usr/lib/libpcap.so.1 ${INSTALL}/usr/lib/libpcap.so.0.8
  rm -rf ${INSTALL}/usr/bin
}
