# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/glib/package.mk

PKG_MESON_OPTS_HOST="-Ddefault_library=shared \
                     -Dinstalled_tests=false \
                     -Dlibmount=disabled \
                     -Dintrospection=disabled \
                     -Dtests=false"

if [ "${ARCH}" == "aarch64" ]; then
  PKG_DEPENDS_TARGET+=" gobject-introspection"
  PKG_MESON_OPTS_TARGET+=" -Dintrospection=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dintrospection=disabled"
fi

pre_configure_target() {
  if [ "${ARCH}" == "aarch64" ]; then
    # tweak the binary names so that it picks up our
    # wrappers which do the cross-compile with qemu
    sed -e "s|gir_scanner = .*|gir_scanner = files('${TOOLCHAIN}/bin/g-ir-scanner-wrapper')|" \
        -e "s|enable_gir = .*|enable_gir = true|" \
        -e "s|  error('Running binaries|  # error('Running binaries|" \
        -i ${PKG_BUILD}/meson.build

    sed -e "s|override_find_program('g-ir-compiler'|override_find_program('g-ir-compiler-wrapper'|" \
        -i ${PKG_BUILD}/girepository/compiler/meson.build
  fi
}
