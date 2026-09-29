# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="unifdef"
PKG_VERSION="2.12"
PKG_SHA256="fba564a24db7b97ebe9329713ac970627b902e5e9e8b14e19e024eb6e278d10b"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://dotat.at/prog/unifdef/"
PKG_URL="https://dotat.at/prog/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain"
PKG_LONGDESC="Removes #ifdef'd code; a host tool WebKit's build uses."
PKG_TOOLCHAIN="manual"

make_host() {
  make CC="${HOST_CC}" CFLAGS="${HOST_CFLAGS}" unifdef
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
  cp unifdef ${TOOLCHAIN}/bin
}
