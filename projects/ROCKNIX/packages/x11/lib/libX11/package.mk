# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libX11/package.mk

PKG_DEPENDS_HOST="toolchain:host util-macros:host xtrans:host libXau:host libxcb:host xorgproto:host"
