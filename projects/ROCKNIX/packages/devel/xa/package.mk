# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="xa"
PKG_VERSION="2.4.1"
PKG_SHA256="63c12a6a32a8e364f34f049d8b2477f4656021418f08b8d6b462be0ed3be3ac3"
PKG_LICENSE="GPL"
PKG_SITE="http://tinycorelinux.net"
PKG_URL="${PKG_SITE}/15.x/x86/tcz/src/xa/xa-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="xa is a high-speed, two-pass portable cross-assembler."

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
  cp -f file65 ldo65 mkrom.sh printcbm reloc65 uncpk xa ${TOOLCHAIN}/bin
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -f file65 ldo65 mkrom.sh printcbm reloc65 uncpk xa ${INSTALL}/usr/bin
}
