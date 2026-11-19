# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="protobuf"
PKG_VERSION="33.6"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/protocolbuffers/protobuf"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/protobuf-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_HOST="toolchain:host"
PKG_LONGDESC="Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET=" -Dprotobuf_BUILD_TESTS=OFF \
                        -Dprotobuf_BUILD_EXAMPLES=OFF \
                        -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
                        -DBUILD_SHARED_LIBS=OFF \
                        -Dprotobuf_ALLOW_CCACHE=ON"

PKG_CMAKE_OPTS_HOST=${PKG_CMAKE_OPTS_TARGET}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/lib
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/bin
}
