# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/ccache/package.mk

pre_configure_host() {
  export CXXFLAGS+=" -Wno-error=restrict"
}
