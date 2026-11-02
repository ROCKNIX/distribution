# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="wasm4-lr"
PKG_VERSION="9d6c962785cfe3719d0245fd279ecbe98a4dbb63"
PKG_LICENSE="ISC"
PKG_SITE="https://github.com/aduros/wasm4"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="WASM-4 is a low-level fantasy game console for building small games with WebAssembly. Game cartridges (ROMs) are small, self-contained .wasm files that can be built with any programming language that compiles to WebAssembly."
PKG_TOOLCHAIN='manual'

make_target() {
  cd ${PKG_BUILD}/runtimes/native
  cmake -B build -DBUILD_TARGET=wasm4_libretro
  cmake --build build --target wasm4_libretro
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/runtimes/native/build/wasm4_libretro.so ${INSTALL}/usr/lib/libretro
}
