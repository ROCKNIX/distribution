# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="xterm"
PKG_VERSION="379"
PKG_LICENSE="MIT"
PKG_SITE="http://invisible-island.net/archives/xterm"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain ncurses xwayland libXaw libXpm"
PKG_LONGDESC="Terminal emulator for X11."


PKG_CONFIGURE_OPTS_TARGET="--disable-full-tgetent"
