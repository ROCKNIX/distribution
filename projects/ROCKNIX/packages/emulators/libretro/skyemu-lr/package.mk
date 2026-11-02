# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="skyemu-lr"
PKG_VERSION="f4d3238bf42da483ed1b7cc35649398b2110e4b4"
PKG_SHA256="0e0224e6364b1f89ad6c557c184cc98a0be87669689fd146f2cd02cec5151533"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/skylersaleh/SkyEmu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="SkyEmu is a low level GameBoy, GameBoy Color, Game Boy Advance, and DS emulator."
PKG_DEPENDS_TARGET="toolchain retroarch SDL2 openssl curl"

PKG_CMAKE_OPTS_TARGET="-DENABLE_RETRO_ACHIEVEMENTS=ON \
                       -DRETRO_CORE_ONLY=ON"

make_target() {
  cmake --build ${PKG_BUILD}/.${TARGET_NAME} --target skyemu_libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/skyemu_libretro.so ${INSTALL}/usr/lib/libretro
}
