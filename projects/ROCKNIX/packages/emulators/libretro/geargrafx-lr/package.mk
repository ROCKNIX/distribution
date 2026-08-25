# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="geargrafx-lr"
PKG_VERSION="ca629d729a3691f1aa0d5cd7b0fa687e7d56c394"
PKG_SHA256="55406bddfc8476543feb7a557fea5d19c585313f4f84f37e0cd3a0899e4bed71"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/drhelius/Geargrafx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Geargrafx is a very accurate, cross-platform TurboGrafx-16 / PC Engine / SuperGrafx / PCE CD-ROM² emulator written in C++ that runs on Windows, macOS, Linux, BSD and RetroArch."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platforms/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platforms/libretro/geargrafx_libretro.so ${INSTALL}/usr/lib/libretro
}
