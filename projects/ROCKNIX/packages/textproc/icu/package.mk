# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/icu/package.mk

unset PKG_BUILD_FLAGS

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
