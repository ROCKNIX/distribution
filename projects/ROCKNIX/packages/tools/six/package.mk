# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="six"
PKG_VERSION="02c3bca"
PKG_SHA256="3b7d1c758d67963007324e0c364fd69c9ed329e953d6d26c1380ba26a63a2f52"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/benjaminp/six"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 setuptools:host"
PKG_LONGDESC="Python 2 and 3 compatibility library "
PKG_TOOLCHAIN="python"

post_makeinstall_target() {
  python_remove_source
}
