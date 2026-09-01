# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="freechaf-lr"
PKG_VERSION="76c7a84f1f7e80f3e6f2bba96fe100cb24e99124"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/libretro/FreeChaF"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="FreeChaF is a libretro emulation core for the Fairchild ChannelF / Video Entertainment System designed to be compatible with joypads from the SNES era forward."

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a freechaf_libretro.so ${INSTALL}/usr/lib/libretro
}
