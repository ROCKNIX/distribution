# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="glu"
PKG_VERSION="9.0.3"
PKG_LICENSE="OSS"
PKG_SITE="https://gitlab.freedesktop.org/mesa/glu/"
PKG_URL="${PKG_SITE}-/archive/glu-${PKG_VERSION}/glu-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain mesa"
PKG_NEED_UNPACK="$(get_pkg_directory mesa)"
PKG_LONGDESC="libglu is the The OpenGL utility library"
