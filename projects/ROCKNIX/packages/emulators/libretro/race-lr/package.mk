# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="race-lr"
PKG_VERSION="c7810dd7f172827bfa2004813bc000b13786636b"
PKG_SHA256="9a7c2e4041753c8235f403bfa48f93b6049509f857d45e42e0657efffbebd898"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/RACE"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="This is the RACE NGPC emulator modified by theelf to run on the PSP."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a race_libretro.so ${INSTALL}/usr/lib/libretro
}
