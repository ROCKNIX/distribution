# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dbussy"
PKG_VERSION="bd4a5c3ddd2a59df2c10d84cfa7902102b68f050"
PKG_SHA256="4541064e19277784d0098d9010967488efb1e007bfa309ea140cefb724713317"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://gitlab.com/ldo/dbussy"
PKG_URL="https://gitlab.com/ldo/dbussy/-/archive/${PKG_VERSION}/dbussy-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 dbus setuptools:host"
PKG_LONGDESC="DBussy is a wrapper around libdbus, written in pure Python"
PKG_TOOLCHAIN="python"

post_makeinstall_target() {
  python_remove_source
}
