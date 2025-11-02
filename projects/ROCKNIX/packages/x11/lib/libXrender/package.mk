# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libXrender/package.mk

PKG_DEPENDS_HOST="toolchain:host util-macros:host libX11:host"

PKG_CONFIGURE_OPTS_HOST="--enable-malloc0returnsnull"

post_configure_host() {
  libtool_remove_rpath libtool
}
