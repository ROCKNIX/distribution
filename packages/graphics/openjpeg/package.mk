# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="openjpeg"
PKG_VERSION="2.5.4"
PKG_SHA256="a695fbe19c0165f295a8531b1e4e855cd94d0875d2f88ec4b61080677e27188a"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://www.openjpeg.org/"
PKG_URL="https://github.com/uclouvain/openjpeg/archive/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib libpng tiff"
PKG_LONGDESC="JPEG 2000 codec; WebKit decodes JPEG 2000 images with it."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=ON \
                       -DBUILD_STATIC_LIBS=OFF \
                       -DBUILD_CODEC=OFF \
                       -DBUILD_DOC=OFF \
                       -DBUILD_TESTING=OFF"
