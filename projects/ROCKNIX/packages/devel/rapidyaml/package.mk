# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rapidyaml"
PKG_VERSION="0.12.1"
PKG_SHA256="e9efcdd17f86287748793cf21d106e461fcad8d103a3e5a23632afe93828660d"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/biojppm/rapidyaml"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/rapidyaml-${PKG_VERSION}-src.tgz"
PKG_LONGDESC="A library to parse and emit YAML, and do it fast."
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DBUILD_SHARED_LIBS=ON"
