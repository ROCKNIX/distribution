# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mu-lr"
PKG_VERSION="afaeb157b8ba38a4a9bdf426ba663f7efb2cc6f8"
PKG_SHA256="beac284d3027b05b50ef81d966e5b436b41792ce3dbfcf9cef9243130a648db9"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/Mu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="An emulator for the Palm m515 OS ported to libretro."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C ../libretroBuildSystem"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ../libretroBuildSystem/mu_libretro.so ${INSTALL}/usr/lib/libretro
}
