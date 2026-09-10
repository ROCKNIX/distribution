# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pcsx_rearmed-lr"
PKG_VERSION="da2cb8ecd17fd0932ab6d94774c0522beebce6e3"
PKG_SHA256="ff191a349aa88b7156f2c40ae32b7144884eec921542f07508d88715105d175e"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/pcsx_rearmed"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro -C .. GIT_VERSION=${PKG_VERSION} platform=$(if [ "${TARGET_ARCH}" = "x86_64" ]; then echo unix; else echo ${DEVICE}; fi)"

post_unpack() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    case ${TARGET_ARCH} in
      aarch64|x86_64) cp -a ../pcsx_rearmed_libretro.so ${INSTALL}/usr/lib/libretro ;;
      arm) cp -a ../pcsx_rearmed_libretro.so ${INSTALL}/usr/lib/libretro/pcsx_rearmed32_libretro.so ;;
    esac
}
