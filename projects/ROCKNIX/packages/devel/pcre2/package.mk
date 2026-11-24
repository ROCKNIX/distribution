# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/pcre2/package.mk

PKG_CMAKE_OPTS_TARGET="${PKG_CMAKE_OPTS_TARGET//-DBUILD_SHARED_LIBS=OFF/-DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON}"
