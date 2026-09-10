# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gearcoleco-lr"
PKG_VERSION="fd6c7ccca76358b41aff646f85a9c0bbaa69b36a"
PKG_SHA256="54be3e86d4466f3bba4c168d56faba467360c00c0a405702bd5580987868cb87"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/drhelius/Gearcoleco"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Gearcoleco is a very accurate cross-platform ColecoVision emulator written in C++ that runs on Windows, macOS, Linux, BSD, Raspberry Pi and RetroArch."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platforms/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platforms/libretro/gearcoleco_libretro.so ${INSTALL}/usr/lib/libretro
}
