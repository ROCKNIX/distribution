# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vice-lr"
PKG_VERSION="5ebe7d333ab15be57a9dde5f46c29a5bbd5f44f8"
PKG_SHA256="45ed7b653473e0a819fdca3679e3797c4606edb8d115afa5fd26265044431225"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/vice-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Versatile Commodore 8-bit Emulator version 3.0"

make_target() {
  if [ ! -d "built" ]; then
    mkdir built
  fi

  for EMUTYPE in x128 x64sc x64dtv xscpu64 xplus4 xvic xcbm5x0 xcbm2 xpet x64; do
    make clean
    make platform=unix EMUTYPE=${EMUTYPE}
    mv vice_*_libretro.so built
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a built/vice_x128_libretro.so ${INSTALL}/usr/lib/libretro
    cp -a built/vice_x64_libretro.so ${INSTALL}/usr/lib/libretro
    cp -a built/vice_xplus4_libretro.so ${INSTALL}/usr/lib/libretro
    cp -a built/vice_xvic_libretro.so ${INSTALL}/usr/lib/libretro
    cp -a built/vice_xpet_libretro.so ${INSTALL}/usr/lib/libretro
}
