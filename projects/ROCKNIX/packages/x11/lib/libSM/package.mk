# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libSM/package.mk

PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--enable-static/--disable-static}"
PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/--disable-shared/--enable-shared}"
