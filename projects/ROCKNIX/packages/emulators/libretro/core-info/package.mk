# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="core-info"
PKG_VERSION="b03bfc451381e1a5eb92fda9e56a1e81bfeb92c9"
PKG_SHA256="c6aa4a90b041a57037ec8ebf3caef304062523fbc2fd1e4733b7aa4668ed9a27"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/libretro-core-info"
PKG_URL="https://github.com/libretro/libretro-core-info/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Mirror of libretro's core info files"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  ${TOOLCHAIN}/bin/rename mednafen beetle ${PKG_BUILD}/*.info

  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/*.info ${INSTALL}/usr/lib/libretro/
    cp -a ${PKG_BUILD}/pcsx_rearmed_libretro.info ${INSTALL}/usr/lib/libretro/pcsx_rearmed32_libretro.info
    cp -a ${PKG_BUILD}/flycast_libretro.info ${INSTALL}/usr/lib/libretro/flycast2021_libretro.info
}
