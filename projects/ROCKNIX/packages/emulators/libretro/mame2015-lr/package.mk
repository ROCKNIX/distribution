# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mame2015-lr"
PKG_VERSION="283e04b03c121db9be12632d6bad2fc3e8707248"
PKG_SHA256="8529bb074b1814c6577f928d852f4d443c4cdf1cd2a455c742f9ff2b339f8160"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame2015-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Late 2014/Early 2015 version of MAME (0.160-ish) for libretro. Compatible with MAME 0.160 romsets."
PKG_BUILD_FLAGS="-lto"

pre_make_target() {
  export REALCC=${CC}
  export CC=${CXX}
  export LD=${CXX}
  make maketree
}

pre_configure_target() {
  case ${ARCH} in
    arm|aarch64)
      PKG_MAKE_OPTS_TARGET=" platform=armv8-neon-hardfloat-cortex-a53"
      sed -i 's/LDFLAGS += -Wl,--fix-cortex-a8 -Wl,--no-as-needed//g' Makefile
      sed -i 's/CCOMFLAGS += -mstructure-size-boundary=32//g' Makefile
      ;;
  esac
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a mame2015_libretro.so ${INSTALL}/usr/lib/libretro
}
