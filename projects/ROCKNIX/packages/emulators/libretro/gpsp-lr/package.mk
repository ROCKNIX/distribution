# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gpsp-lr"
PKG_VERSION="8d268a6bb2cd799f8f2791ebb544a7ef550cfc6f"
PKG_SHA256="0b7833468c5fee9da7dcb433de0c11701fbb0734dba2c8b3630bd054d607e004"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/gpsp"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
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
