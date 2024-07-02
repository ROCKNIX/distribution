# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rapidjson"
PKG_VERSION="ab1842a2dae061284c0a62dca1cc6d5e7e37e346"
PKG_SHA256="208f551cd08586a0a642cbd8d2c59783419c8a7e4f7552e13a19bc4e806403a9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/miloyip/rapidjson"
PKG_URL="https://github.com/Tencent/rapidjson/archive/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A fast JSON parser/generator for C++ with both SAX/DOM style API"

PKG_CMAKE_OPTS_TARGET="-DRAPIDJSON_BUILD_DOC=OFF \
                       -DRAPIDJSON_BUILD_EXAMPLES=OFF \
                       -DRAPIDJSON_BUILD_TESTS=OFF \
                       -DRAPIDJSON_BUILD_THIRDPARTY_GTEST=OFF \
                       -DRAPIDJSON_BUILD_ASAN=OFF \
                       -DRAPIDJSON_BUILD_UBSAN=OFF \
                       -DRAPIDJSON_HAS_STDSTRING=ON"
