# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present AmberELEC (https://github.com/AmberELEC)

PKG_NAME="emuscv-lr"
PKG_VERSION="dfce10df090ce3f5eb23bdbee289702ec1478246"
#PKG_ARCH="aarch64"
PKG_SITE="https://gitlab.com/MaaaX-EmuSCV/libretro-emuscv"
PKG_URL="${PKG_SITE}.git"
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
  cp ${PKG_BUILD}/emuscv_libretro.so ${INSTALL}/usr/lib/libretro/
}
