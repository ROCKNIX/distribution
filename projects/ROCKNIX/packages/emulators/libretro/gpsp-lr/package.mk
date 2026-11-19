# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gpsp-lr"
PKG_VERSION="5819380c2ffb0900219d700a382ee68c464ebb99"
PKG_SHA256="1dfc919966cd58ce1d8f2580041d9bffe2e313d9442260c713ed0286a048a733"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/gpsp"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain retroarch"
PKG_LONGDESC="gameplaySP is a Gameboy Advance emulator for Playstation Portable"

make_target() {
  if [ "${ARCH}" = "arm" ]; then
    make platform=${DEVICE}
  else
    :
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    if [ "${ARCH}" = "aarch64" ]; then
      cp -a ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/gpsp-*/usr/lib/libretro/gpsp_libretro.so ${INSTALL}/usr/lib/libretro
    else
      cp -a ${PKG_BUILD}/gpsp_libretro.so ${INSTALL}/usr/lib/libretro
    fi
}
