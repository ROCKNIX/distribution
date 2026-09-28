# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/compress/xz/package.mk

PKG_BUILD_FLAGS="+pic +pic:host"

PKG_CONFIGURE_OPTS_HOST="--disable-shared \
                         --enable-static \
                         --disable-lzmadec \
                         --disable-lzmainfo \
                         --enable-lzma-links \
                         --disable-nls \
                         --disable-scripts \
                         --enable-symbol-versions=no"

PKG_CONFIGURE_OPTS_TARGET="--enable-shared \
                           --disable-static \
                           --enable-symbol-versions=yes"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
