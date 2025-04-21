# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gpsp-lr"
PKG_VERSION="66ced08c693094f2eaefed5e11bd596c41028959"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/gpsp"
PKG_URL="https://github.com/libretro/gpsp/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="gameplaySP is a Gameboy Advance emulator for Playstation Portable"
PKG_TOOLCHAIN="make"
PKG_PATCH_DIRS+="${DEVICE}"

if [ "${ARCH}" = "arm" ]; then
  make_target() {
    make CC=${CC} platform=${DEVICE}
  }
else
  make_target() {
    :
  }
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  if [ "${ARCH}" = "aarch64" ]; then
    cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/gpsp-*/.install_pkg/usr/lib/libretro/gpsp_libretro.so ${INSTALL}/usr/lib/libretro
  else
    cp ${PKG_BUILD}/gpsp_libretro.so ${INSTALL}/usr/lib/libretro
  fi
}
