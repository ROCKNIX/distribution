# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libSM/package.mk

PKG_CONFIGURE_OPTS_TARGET="--disable-static \
                           --enable-shared \
                           --with-libuuid \
                           --without-xmlto \
                           --without-fop"
