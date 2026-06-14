# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/audio/opus/package.mk

if [ "${TARGET_ARCH}" = "arm" ]; then
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-rtcd --disable-intrinsics --disable-asm"
fi
