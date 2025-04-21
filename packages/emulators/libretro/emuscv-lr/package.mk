# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="emuscv-lr"
PKG_VERSION="dfce10df090ce3f5eb23bdbee289702ec1478246"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.com/MaaaX-EmuSCV/libretro-emuscv"
PKG_URL="https://gitlab.com/MaaaX-EmuSCV/libretro-emuscv/-/archive/${PKG_VERSION}/libretro-emuscv-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain bin2c:host"
PKG_LONGDESC="An EPOCH/YENO Super Cassette Vision (1984) home video game emulator for Libretro"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C . platform=unix"

pre_configure_target() {
  export TERM=xterm
  CXXFLAGS+=" -I$(get_build_dir glibc)/sysdeps/unix/sysv/linux/x86"
  sed -i 's~tools/bin2c/~'${TOOLCHAIN}'/usr/bin/~g' Makefile.libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/emuscv_libretro.so ${INSTALL}/usr/lib/libretro
}
