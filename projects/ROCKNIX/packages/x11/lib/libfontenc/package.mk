# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libfontenc/package.mk

PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Ddefault_library=static/-Ddefault_library=shared}"
