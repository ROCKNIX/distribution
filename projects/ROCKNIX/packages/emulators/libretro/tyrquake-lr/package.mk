# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="tyrquake-lr"
PKG_VERSION="67db338ff4d27fdbcead61d4e54938d758ae62cb"
PKG_SHA256="57d42b71613c092303cf8be817ef3d84c867e3c7ec9d61f06bd890c26d4c15c2"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/tyrquake"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Libretro port of Tyrquake (Quake 1 engine)"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a tyrquake_libretro.so ${INSTALL}/usr/lib/libretro
}
