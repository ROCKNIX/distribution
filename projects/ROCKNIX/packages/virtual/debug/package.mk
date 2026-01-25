# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/virtual/debug/package.mk

PKG_DEPENDS_TARGET+=" nvtop apitrace"

# strace is broken on 6.19 kernels, so temporarily remove
PKG_DEPENDS_TARGET=${PKG_DEPENDS_TARGET//"strace"/}
