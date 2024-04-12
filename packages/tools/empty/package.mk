# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="empty"
PKG_VERSION="0.6.23c"
PKG_LICENSE="GPL"
PKG_SITE="http://empty.sourceforge.net/"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_URL="http://downloads.sourceforge.net/sourceforge/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tgz"
PKG_LONGDESC="Run applications under pseudo-terminal sessions"


make_target() {
  make CC=${CC}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp empty ${INSTALL}/usr/bin/
}
