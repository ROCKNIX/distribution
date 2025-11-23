# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libretro-database"
PKG_VERSION="fbcc8c1c24d8b20b6aaca95b4da6a2f39ad85f05"
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
