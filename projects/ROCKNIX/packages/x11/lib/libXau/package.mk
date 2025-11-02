# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libXau/package.mk

PKG_DEPENDS_HOST="toolchain:host util-macros:host xorgproto:host"

PKG_MESON_OPTS_HOST="-Ddefault_library=shared \
                       -Dprefer_static=false \
                       -Dxthreads=true"

PKG_MESON_OPTS_TARGET="-Ddefault_library=shared \
                       -Dprefer_static=false \
                       -Dxthreads=true"
