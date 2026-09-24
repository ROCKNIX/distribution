# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/sysutils/libevdev/package.mk

case ${DEVICE} in
  AMD64)
    PKG_VERSION="1.13.7"
    PKG_SHA256="0caf824971108f15bb2ad356433bae198d7d3bf1e82d43f63626e069e060bfa6"
    ;;
esac
PKG_URL="https://www.freedesktop.org/software/libevdev/${PKG_NAME}-${PKG_VERSION}.tar.xz"
