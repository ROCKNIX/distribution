# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gst-plugins-base/package.mk

PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET//-Dgl=disabled/-Dgl=enabled}"

post_configure_target() {
  find "${PKG_BUILD}" -path '*subprojects/graphene/include/graphene-config.h' -exec \
    sed -i 's/^#\(\s*\)#define GRAPHENE_USE_AVX/#\1define GRAPHENE_USE_AVX/' {} +
}
