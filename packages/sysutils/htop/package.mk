# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="htop"
PKG_VERSION="4102862d12695cdf003e2d51ef6ce5984b7136d7" # 3.2.2
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/htop-dev/htop"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_LONGDESC="An interactive process viewer for Unix."
PKG_TOOLCHAIN="autotools"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -lreadline -lncursesw -ltinfow"
  PKG_CONFIGURE_OPTS_TARGET="--disable-unicode"
}
