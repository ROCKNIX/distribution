# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="icu"
PKG_VERSION="74.1"
PKG_SHA256="86ce8e60681972e60e4dcb2490c697463fcec60dd400a5f9bffba26d0b52b8d0"
PKG_LICENSE="Custom"
PKG_SITE="http://www.icu-project.org"
PKG_URL="https://github.com/unicode-org/icu/releases/download/release-${PKG_VERSION//./-}/icu4c-${PKG_VERSION//./_}-src.tgz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain icu:host"
PKG_LONGDESC="International Components for Unicode library."
PKG_TOOLCHAIN="configure"

#PKG_BUILD_FLAGS="-sysroot"

configure_package() {
  PKG_CONFIGURE_SCRIPT="${PKG_BUILD}/source/configure"
  PKG_CONFIGURE_OPTS_HOST="--disable-layout \
                           --disable-layoutex \
                           --enable-renaming \
                           --disable-samples \
                           --disable-tests \
                           --enable-tools \
                           --disable-extras"

  PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_HOST} \
                             --with-cross-build=${PKG_BUILD}/.${HOST_NAME}"

}

