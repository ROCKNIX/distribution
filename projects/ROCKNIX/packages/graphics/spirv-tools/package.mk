# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

. ${ROOT}/packages/graphics/spirv-tools/package.mk

# core builds the target side static and with the tools; we want the shared
# library only
PKG_CMAKE_OPTS_TARGET="-DSPIRV_SKIP_TESTS=ON \
                       -DSPIRV_SKIP_EXECUTABLES=ON \
                       -DBUILD_SHARED_LIBS=ON"
