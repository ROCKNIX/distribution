# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/graphics/libjpeg-turbo/package.mk

PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET//-DENABLE_STATIC=ON/-DENABLE_STATIC=OFF}"
PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET//-DENABLE_SHARED=OFF/-DENABLE_SHARED=ON}"

if [[ ${TARGET_ARCH} =~ i*86|x86_64 ]]; then
  PKG_DEPENDS_HOST+=" nasm:host"
  PKG_DEPENDS_TARGET+=" nasm:host"
fi

