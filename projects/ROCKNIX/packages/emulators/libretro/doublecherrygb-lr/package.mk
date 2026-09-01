# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="doublecherrygb-lr"
PKG_VERSION="1587acddb2b575ed2e6c6b1e2c2daaa26bb42134"
PKG_SHA256="472783d978a7309bb47f093e588b5951367ce54c120ef785de04b677b2683ccc"
PKG_LICENSE="AGPL-2.0-or-later"
PKG_SITE="https://github.com/TimOelrichs/doublecherryGB-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="DoubleCherryGB is an open source (GPLv2) GB/GBC emulator."

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/DoubleCherryGB_libretro.so ${INSTALL}/usr/lib/libretro
}
