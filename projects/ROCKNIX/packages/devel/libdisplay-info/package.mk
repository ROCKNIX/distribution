# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/libdisplay-info/package.mk

PKG_VERSION="0.3.0"
PKG_SHA256="6ae77cd937f9cf7d1321d35c116062c4911e8447010a6a713ac4286f7a9d5987"
PKG_URL="https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/${PKG_VERSION}/downloads/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain hwdata:host"
