# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libretro-database"
PKG_VERSION="4de37d2c8042d9d0f608c43006c9b35438c536ce"
PKG_SHA256="cd8d09c2408e193d2ea4925de60afcf01523fa8cf269c38b5ae5c2580cd56c1f"
PKG_LICENSE=""
PKG_SITE="https://github.com/libretro/libretro-database"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="Repository containing cheatcode files, content data files, etc."
PKG_TOOLCHAIN="manual"

post_unpack() {
  sed -i '/cp -ar -t .* cht cursors/s/ rdb//' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/libretro-database" -C "${PKG_BUILD}"
}
