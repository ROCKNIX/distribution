# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="uzem-lr"
PKG_VERSION="d991ee94547c8294abc1c4cb73d63116aa58b5bc"
PKG_SHA256="b51bc49a11891c97cb98228798de9dcb9d15327f15aac21cab190d184d2e1d68"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/libretro-uzem"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A retro-minimalist game console engine for the ATMega644"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a uzem_libretro.so ${INSTALL}/usr/lib/libretro
}
