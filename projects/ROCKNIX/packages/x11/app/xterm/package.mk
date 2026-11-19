# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="xterm"
PKG_VERSION="410"
PKG_SHA256="7ba9fbb303dd3d95d06ca24360d019048d84e5822dc6fe722cd77369bdbf231f"
PKG_LICENSE="MIT"
PKG_SITE="http://invisible-island.net/archives/xterm"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain ncurses xwayland libXaw libXpm"
PKG_LONGDESC="Terminal emulator for X11."

PKG_CONFIGURE_OPTS_TARGET="--disable-full-tgetent"
