# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="stb"
PKG_VERSION="f75e8d1cad7d90d72ef7a4661f1b994ef78b4e31"
PKG_SHA256="bc6ccf08bec08fea8ef423c7117dca06d2f62d2b27c5485f6865584b533fa7fa"
PKG_LICENSE="MIT OR Unlicense"
PKG_SITE="https://github.com/nothings/stb"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Single-file public domain libraries for C/C++"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include/stb
    cp -a ${PKG_BUILD}/*.h ${SYSROOT_PREFIX}/usr/include/stb
}
