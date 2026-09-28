# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/graphics/gdk-pixbuf/package.mk

PKG_DEPENDS_TARGET+=" zlib"

pre_configure_target() {
  PKG_MESON_OPTS_TARGET="--wrap-mode=nodownload \
                         -Ddocumentation=false \
                         -Dintrospection=disabled \
                         -Dman=false \
                         -Drelocatable=false \
                         -Dinstalled_tests=false \
                         -Dglycin=disabled \
                         -Dtests=false"

  if [ "${DISPLAYSERVER}" != "x11" ]; then
    PKG_MESON_OPTS_TARGET+=" -Dbuiltin_loaders=all"
  fi

  export TARGET_LDFLAGS="-L${SYSROOT_PREFIX}/usr/lib -lz"
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/gdk-pixbuf-2.0/2.10.0/
    cp ${PKG_DIR}/config/* ${INSTALL}/usr/lib/gdk-pixbuf-2.0/2.10.0/
}
