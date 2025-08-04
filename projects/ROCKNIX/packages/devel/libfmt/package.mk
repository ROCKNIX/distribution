# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/libfmt/package.mk

case ${DEVICE} in
  SM8250|SM8550|SDM845|AMD64)
    ;;
  *)
    PKG_VERSION="9.1.0"
    PKG_SHA256=""
    PKG_URL="https://github.com/fmtlib/fmt/archive/${PKG_VERSION}.tar.gz"
    ;;
esac
