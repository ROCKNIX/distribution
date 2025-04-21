# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dosbox-pure-lr"
PKG_VERSION="9e468f0087454c6c1b68975ead933977d5cf33b2"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/schellingb/dosbox-pure"
PKG_URL="https://github.com/schellingb/dosbox-pure/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A port of DOSBox to libretro"
PKG_TOOLCHAIN="make"
PKG_PATCH_DIRS+="${DEVICE}"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  ${STRIP} --strip-debug dosbox_pure_libretro.so
  cp dosbox_pure_libretro.so ${INSTALL}/usr/lib/libretro
}
