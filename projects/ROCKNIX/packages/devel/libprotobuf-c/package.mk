# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libprotobuf-c"
PKG_VERSION="4719fdd7760624388c2c5b9d6759eb6a47490626"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/protobuf-c/protobuf-c"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain protobuf"
PKG_DEPENDS_HOST="toolchain:host protobuf:host"
PKG_LONGDESC="C implementation of the Google Protocol Buffers data serialization format"
PKG_TOOLCHAIN="autotools"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/bin
}