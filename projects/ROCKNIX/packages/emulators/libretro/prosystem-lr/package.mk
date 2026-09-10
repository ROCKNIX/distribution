# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="prosystem-lr"
PKG_VERSION="8a88014287c7a01cd568067e5a557d0a2b2a051f"
PKG_SHA256="23401c8b104ef24db111bbc4b13e37f224ffe16febfb89c704c70cdb269603bc"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/prosystem-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of ProSystem to libretro."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a prosystem_libretro.so ${INSTALL}/usr/lib/libretro
}
