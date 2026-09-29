# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="woff2"
PKG_VERSION="1.0.2"
PKG_SHA256="add272bb09e6384a4833ffca4896350fdb16e0ca22df68c0384773c67a175594"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/google/woff2"
PKG_URL="https://github.com/google/woff2/archive/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain brotli"
PKG_LONGDESC="WOFF2 web font decoder, required by WebKit for downloadable fonts."
PKG_TOOLCHAIN="cmake"

# Two things are stale rather than wrong in woff2 1.0.2 -- upstream has not
# tagged a release since 2020. It declares cmake_minimum_required(VERSION 3.0),
# which current CMake refuses outright; and its headers use uint8_t without
# including <cstdint>, which older GCC provided transitively and GCC 15 does
# not (see patches/). The project itself is fine.
PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=ON \
                       -DCANONICAL_PREFIXES=ON \
                       -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
