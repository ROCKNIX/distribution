# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="fribidi"
PKG_VERSION="1.0.16"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/fribidi/fribidi"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/fribidi-${PKG_VERSION}.tar.xz"
PKG_TOOLCHAIN="meson"
TARGET_MESON_OPT="--enable-shared docs=false bin=false tests=false"

#make_target() {
  #cd ${PKG_BUILD}
  #./autogen.sh
  #${PKG_BUILD}/meson.build
  #./configure
  #./make
  #./make install
  #cp -P ${INSTALL}/usr/lib/libfribidi.a ${INSTALL}/usr/lib/libfribidi.so.0
#}
