# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="neocd_lr"
PKG_VERSION="b1e04c738cb48a1dae0574b8877f6a116d270ca1"
PKG_SHA256="fac1ec580812ce7aa962498450e1b1cc8896a786eeb2f16cfe28807dc13d2418"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/neocd_libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch flac libogg libvorbis"
PKG_LONGDESC="Neo Geo CD emulator for libretro "

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/neocd_libretro.so ${INSTALL}/usr/lib/libretro
}
