# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="core-info"
PKG_VERSION="445421549abc0638a2f5ecf05db8437e580dcc69"
PKG_SHA256="99901524a88c9c4dba3eb03a15eaa314255e9f617bccbd9f3612d626178a1fe5"
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
