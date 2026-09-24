# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="nxengine-lr"
PKG_VERSION="fd1c0686f8b4c0aea9b5addbc077e3ad7da23bb7" # 2026-08-22
PKG_SHA256="81aa24816218c2fa0ddd0f429aa20e663ed903ff573633be8bc5bc812eeb38b7"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/nxengine-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="NXEngine, an open-source rewrite of the Cave Story engine"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a nxengine_libretro.so ${INSTALL}/usr/lib/libretro
}
