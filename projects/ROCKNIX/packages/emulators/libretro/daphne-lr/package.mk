# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="daphne-lr"
PKG_VERSION="6f1695dd1f376060666eec0a416ff56bb6c9cccc"
PKG_SHA256="04181eaa570acdb384920b2363eabf07b1d6d64701e806b852435aec0aa587ee"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/daphne"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="This is a Daphne core"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a daphne_libretro.so ${INSTALL}/usr/lib/libretro
}

