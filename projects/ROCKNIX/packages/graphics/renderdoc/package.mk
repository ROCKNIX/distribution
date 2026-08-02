# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="renderdoc"
PKG_VERSION="v1.44"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/baldurk/renderdoc"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="RenderDoc is a stand-alone graphics debugging tool."
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-sysroot"

PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release \
                        -DENABLE_QRENDERDOC=OFF \
                        -DENABLE_PYRENDERDOC=OFF \
                        -DCMAKE_CROSSCOMPILING=ON \
                        -DHOST_NATIVE_CPP_COMPILER=/usr/bin/g++"