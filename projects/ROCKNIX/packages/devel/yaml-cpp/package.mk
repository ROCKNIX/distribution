# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="yaml-cpp"
PKG_VERSION="0.9.0"
PKG_SHA256="25cb043240f828a8c51beb830569634bc7ac603978e0f69d6b63558dadefd49a"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/jbeder/yaml-cpp"
PKG_URL="${PKG_SITE}/archive/yaml-cpp-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A YAML parser and emitter in C++."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DYAML_BUILD_SHARED_LIBS=OFF \
                       -DYAML_CPP_BUILD_TESTS=OFF \
                       -DYAML_CPP_BUILD_TOOLS=OFF \
                       -DYAML_CPP_FORMAT_SOURCE=OFF"
