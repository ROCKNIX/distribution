# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="skyemu-lr"
PKG_VERSION="46efbcbdb3b902373a09f4724e6d3b1a5acc4af3"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/skylersaleh/SkyEmu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="SkyEmu is a low level GameBoy, GameBoy Color, Game Boy Advance, and DS emulator."
PKG_DEPENDS_TARGET="toolchain SDL2 openssl curl"
PKG_TOOLCHAIN="cmake"
PKG_PATCH_DIRS+="${DEVICE}"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DENABLE_RETRO_ACHIEVEMENTS=ON \
                           -DRETRO_CORE_ONLY=ON"
}

make_target() {
  cmake --build ${PKG_BUILD}/.${TARGET_NAME} --target skyemu_libretro --config Release}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/skyemu_libretro.so ${INSTALL}/usr/lib/libretro/
}
