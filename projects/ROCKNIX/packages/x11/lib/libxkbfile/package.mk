# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libxkbfile/package.mk

PKG_MESON_OPTS_TARGET="-Ddefault_library=shared -Dprefer_static=false"
