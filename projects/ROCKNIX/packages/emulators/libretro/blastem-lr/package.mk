# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="blastem-lr"
PKG_VERSION="542164dc99a8c72daaa0ad179af1df4a434abdff" # 2026-09-20
PKG_SHA256="a03044ba42dae4f133b01f6c2bc79474c273b9e07f052ed5bb10b81d5190bc77"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/blastem"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="BlastEm, a highly accurate Sega Genesis/Mega Drive emulator"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a blastem_libretro.so ${INSTALL}/usr/lib/libretro
}
