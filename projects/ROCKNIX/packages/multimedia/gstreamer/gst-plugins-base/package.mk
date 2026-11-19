# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/multimedia/gstreamer/gst-plugins-base/package.mk

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES} wayland wayland-protocols"
fi

post_unpack() {
  rm -f ${PKG_BUILD}/subprojects/gl-headers.wrap
}

eval "core_$(declare -f pre_configure_target)"
pre_configure_target() {
  core_pre_configure_target
  if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
    PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dgl=disabled/-Dgl=enabled -Dgl_api=gles2 -Dgl_platform=egl -Dgl_winsys=wayland,egl}"
  fi
}

post_configure_target() {
  find "${PKG_BUILD}" -path '*subprojects/graphene/include/graphene-config.h' -exec \
    sed -i 's/^#\(\s*\)#define GRAPHENE_USE_AVX/#\1define GRAPHENE_USE_AVX/' {} +
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/lib/gstreamer-1.0/include
  safe_remove ${INSTALL}/usr/lib/pkgconfig
  safe_remove ${INSTALL}/usr/share
}
