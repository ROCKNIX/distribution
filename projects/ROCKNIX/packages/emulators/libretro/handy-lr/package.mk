# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="handy-lr"
PKG_VERSION="bc55d462f0b2d6b073ea93dc552ebd73cec60fd1"
PKG_SHA256="65ad333df22aab7f3c8156c21ffd0b8da1ef09c7a7f1775df964b89986aa7324"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/libretro/libretro-handy"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="K. Wilkins' Atari Lynx emulator Handy for libretro"

case ${ARCH} in
  aarch64) PKG_MAKE_OPTS_TARGET="platform=emuelec" ;;
  arm) PKG_MAKE_OPTS_TARGET="platform=classic_armv8_a35" ;;
esac


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a handy_libretro.so ${INSTALL}/usr/lib/libretro/
}
