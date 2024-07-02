# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libunwind"
PKG_VERSION="1.8.1"
PKG_SHA256="ddf0e32dd5fafe5283198d37e4bf9decf7ba1770b6e7e006c33e6df79e6a6157"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libunwind/libunwind"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/libunwind-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="library to determine the call-chain of a program"
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --disable-minidebuginfo \
                           --disable-documentation \
                           --disable-tests"

makeinstall_target() {
  make DESTDIR=${SYSROOT_PREFIX} install
}
