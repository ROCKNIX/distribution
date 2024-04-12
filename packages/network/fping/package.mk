# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fping"
PKG_VERSION="5.1"
PKG_LICENSE="GPL"
PKG_SITE="http://fping.org/"
PKG_URL="http://fping.org/dist/fping-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="auto"

PKG_CONFIGURE_OPTS_TARGET="--sbindir=/usr/bin"
