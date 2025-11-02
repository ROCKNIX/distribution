# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/libxcb/package.mk

PKG_DEPENDS_HOST="toolchain:host util-macros:host Python3:host xcb-proto:host libpthread-stubs:host libXau:host"
