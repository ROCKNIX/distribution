# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/x11/lib/pixman/package.mk

if [ "${TARGET_ARCH}" = arm ]; then
  if target_has_feature neon; then
    PIXMAN_NEON="-Dneon=enabled"
  else
    PIXMAN_NEON="-Dneon=disabled"
  fi
  PIXMAN_CONFIG="-Dmmx=disabled -Dsse2=disabled -Dvmx=disabled -Darm-simd=enabled ${PIXMAN_NEON} -Diwmmxt=disabled"
elif [ "${TARGET_ARCH}" = aarch64 ]; then
  PIXMAN_CONFIG="-Dmmx=disabled -Dsse2=disabled -Dvmx=disabled -Darm-simd=disabled -Dneon=disabled -Diwmmxt=disabled"
elif [ "${TARGET_ARCH}" = x86_64  ]; then
  PIXMAN_CONFIG="-Dmmx=enabled -Dsse2=enabled -Dssse3=disabled -Dvmx=disabled -Darm-simd=disabled -Dneon=disabled"
fi
