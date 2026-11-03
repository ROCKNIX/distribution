# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libretro-database"
PKG_VERSION="2fdd069d45883449cecf97deddd493492e77ff29"
PKG_SHA256="cdf00f661a4dce08673e3f58b6a952165200e0d2177e0a9fcce5cd7dd3aba912"
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
