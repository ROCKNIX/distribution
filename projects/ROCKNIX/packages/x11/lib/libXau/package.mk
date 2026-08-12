# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libXau/package.mk

PKG_DEPENDS_HOST="toolchain:host util-macros:host xorgproto:host"

PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Ddefault_library=static/-Ddefault_library=shared}"
PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dprefer_static=true/-Dprefer_static=false}"

PKG_MESON_OPTS_HOST="${PKG_MESON_OPTS_TARGET}"
