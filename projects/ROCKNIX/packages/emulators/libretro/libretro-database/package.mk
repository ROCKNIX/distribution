# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libretro-database"
PKG_VERSION="d3075ab69659d351ae3aea7dc4ba53e21d3d9d1e"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/libretro-database"
PKG_URL="https://github.com/libretro/libretro-database/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="Repository containing cheatcode files, content data files, etc."
PKG_TOOLCHAIN="manual"

post_unpack() {
  sed -i '/cp -ar -t .* cht cursors/s/ rdb//' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/libretro-database" -C "${PKG_BUILD}"
}
