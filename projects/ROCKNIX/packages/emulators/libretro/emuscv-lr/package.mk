# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="emuscv-lr"
PKG_VERSION="dfce10df090ce3f5eb23bdbee289702ec1478246"
PKG_SHA256="f94c59fc91baa4dc8e96233bf0ec710fe1aaf79baa35c0b5af7fe42f73754fec"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://gitlab.com/MaaaX-EmuSCV/libretro-emuscv"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/libretro-emuscv-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain bin2c:host SDL2"
PKG_DEPENDS_UNPACK="glibc"
PKG_LONGDESC="An EPOCH/YENO Super Cassette Vision (1984) home video game emulator for Libretro"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="platform=unix"

pre_configure_target() {
  export TERM=xterm
  CXXFLAGS+=" -I$(get_build_dir glibc)/sysdeps/unix/sysv/linux/x86"
  sed -i 's~tools/bin2c/~'${TOOLCHAIN}'/usr/bin/~g' Makefile.libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/emuscv_libretro.so ${INSTALL}/usr/lib/libretro
}
