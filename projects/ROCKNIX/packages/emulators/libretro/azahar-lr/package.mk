# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="azahar-lr"
PKG_VERSION="9e6f523a57fac9564ac0bf8286db3c3702d301ec" # tag 2126.1.2
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Azahar - Nintendo 3DS emulator, libretro core"

PKG_CMAKE_OPTS_TARGET="-DENABLE_LIBRETRO=ON \
                       -DENABLE_TESTS=OFF \
                       -DENABLE_LTO=OFF \
                       -DCITRA_WARNINGS_AS_ERRORS=OFF"

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/bin/Release/azahar_libretro.so ${INSTALL}/usr/lib/libretro
}
