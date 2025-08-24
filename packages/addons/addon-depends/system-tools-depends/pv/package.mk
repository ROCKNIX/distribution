# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pv"
PKG_VERSION="1.9.34"
PKG_SHA256="c0626bed6cbef5006b53d3281e8e3ae4b2838729462b21eccf28140eefef6bb1"
PKG_LICENSE="GNU"
PKG_SITE="http://www.ivarch.com/programs/pv.shtml"
PKG_URL="http://www.ivarch.com/programs/sources/pv-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Pipe Viewer can be inserted into any normal pipeline between two processes."
PKG_BUILD_FLAGS="-sysroot -cfg-libs"
