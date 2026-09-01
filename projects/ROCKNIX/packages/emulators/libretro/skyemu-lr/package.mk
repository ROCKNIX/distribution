# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="skyemu-lr"
PKG_VERSION="01516d6798e3652b583e6a366085bb51c43b528d"
PKG_SHA256="479071a294080a746efac57e50dc1e43506bbabeacd133b924452995a08a3b21"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/skylersaleh/SkyEmu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="SkyEmu is a low level GameBoy, GameBoy Color, Game Boy Advance, and DS emulator."
PKG_DEPENDS_TARGET="toolchain SDL2 openssl curl"

PKG_CMAKE_OPTS_TARGET="-DENABLE_RETRO_ACHIEVEMENTS=ON \
                       -DRETRO_CORE_ONLY=ON"

make_target() {
  cmake --build ${PKG_BUILD}/.${TARGET_NAME} --target skyemu_libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/skyemu_libretro.so ${INSTALL}/usr/lib/libretro
}
