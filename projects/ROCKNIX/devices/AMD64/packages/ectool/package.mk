# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ectool"
PKG_VERSION="053c901548b751dd10eeae5e0afae8359290bede"
PKG_LICENSE="GPL"
PKG_SITE="https://review.coreboot.org/coreboot"
PKG_URL="${PKG_SITE}.git"
PKG_ARCH="x86_64"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A simple tool for manipulating the embedded controller."

make_target() {
  cd util/ectool
  export PREFIX=/usr
  make
}
