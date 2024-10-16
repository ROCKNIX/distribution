# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gnulib"
# Match version with GNULIB_REVISION in grub bootstrap.conf
PKG_VERSION="9f48fb992a3d7e96610c4ce8be969cff2d61a01b"
PKG_LICENSE="GPL"
PKG_SITE="https://savannah.gnu.org/git/?group=gnulib"
PKG_URL="http://git.savannah.gnu.org/gitweb/?p=${PKG_NAME}.git;a=snapshot;h=${PKG_VERSION};sf=tgz"
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_LONGDESC="GNU portability library"
PKG_TOOLCHAIN="manual"
