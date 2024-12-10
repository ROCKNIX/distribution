# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="dialog"
PKG_VERSION="1.3-20231002"
PKG_LICENSE="GNU-2.1"
PKG_SITE="https://invisible-island.net/archives/dialog"
PKG_URL="${PKG_SITE}/dialog-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_LONGDESC="This version of dialog, formerly known as cdialog is based on the Debian package for dialog 0.9a"
PKG_TOOLCHAIN="auto"

PKG_CONFIGURE_OPTS_TARGET="--with-ncurses --disable-rpath-hack"


