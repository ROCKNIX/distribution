# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="quicknes-lr"
PKG_VERSION="26bb785c9deddb66a17717b21bb4e328f03ade32"
PKG_SHA256="2e19edc678f1606c9eb4a6807bbc9d71caa519fd917c953d4082929ad56b7795"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/QuickNES_Core"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The QuickNES core library, originally by Shay Green, heavily modified"
PKG_BUILD_FLAGS="-gold"

post_unpack() {
  VERSION='GIT_VERSION ?= '
  VERSION+=${PKG_VERSION:0:7}
  sed -i "s/GIT_VERSION ?= \" \$(shell git describe --dirty --always --tags)\"/${VERSION}/g" ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a quicknes_libretro.so ${INSTALL}/usr/lib/libretro
}
