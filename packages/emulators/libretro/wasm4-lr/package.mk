# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)


PKG_NAME="wasm4-lr"
PKG_VERSION="01765b0929a108e7362e4b34fa8aae64180f7c42"
PKG_LICENSE="ISC"
PKG_SITE="https://github.com/aduros/wasm4"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="WASM-4 is a low-level fantasy game console for building small games with WebAssembly. Game cartridges (ROMs) are small, self-contained .wasm files that can be built with any programming language that compiles to WebAssembly."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN='manual'
PKG_CMAKE_OPTS_TARGET="-DBUILD_TARGET=wasm4_libretro \
                       -DCMAKE_BUILD_TYPE=Release"

make_target() {
  cd ${PKG_BUILD}/runtimes/native
  cmake -B build
  cmake --build build --target wasm4_libretro
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/runtimes/native/build/wasm4_libretro.so ${INSTALL}/usr/lib/libretro/
}
