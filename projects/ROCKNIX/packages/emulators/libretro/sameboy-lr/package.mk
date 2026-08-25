# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sameboy-lr"
PKG_VERSION="aa158a889a48b538a0302873704a34577c8eb67d"
PKG_SHA256="6d80783ac470c15b5be1060e619eda01079f00c1c42fdfbcc65527b7dcd8b5b7"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/SameBoy"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain util-linux:host"
PKG_LONGDESC="Gameboy and Gameboy Color emulator written in C"

PKG_MAKE_OPTS_TARGET="-C libretro BOOTROMS_DIR=${PKG_BUILD}/BootROMs/prebuilt"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a libretro/sameboy_libretro.so ${INSTALL}/usr/lib/libretro
}
