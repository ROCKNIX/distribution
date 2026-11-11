# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="geargrafx-lr"
PKG_VERSION="0ca083267f690205a516bb0a2a8f8c5dd5361e96"
PKG_SHA256="005cd9c63c986d6078afd353bd532e13d6ee1e2ffcad8121ed3f8c3fc62b0590"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/drhelius/Geargrafx"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="Geargrafx is a very accurate, cross-platform TurboGrafx-16 / PC Engine / SuperGrafx / PCE CD-ROM² emulator written in C++ that runs on Windows, macOS, Linux, BSD and RetroArch."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C platforms/libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a platforms/libretro/geargrafx_libretro.so ${INSTALL}/usr/lib/libretro
}
