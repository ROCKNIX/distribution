# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lrps2-lr"
PKG_VERSION="99abf17ca872b15f4850948067802bd169fddee9"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/ps2"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ${OPENGL} libglvnd"
PKG_LONGDESC="LRPS2, the libretro port of the PCSX2 PlayStation 2 emulator"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DCMAKE_POLICY_VERSION_MINIMUM=3.18"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a bin/pcsx2_libretro.so ${INSTALL}/usr/lib/libretro
}
