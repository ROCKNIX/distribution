# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="xa"
PKG_VERSION="2.4.1"
PKG_LICENSE="GPL"
PKG_SITE="https://www.floodgap.com/retrotech/xa/"
PKG_URL="${PKG_SITE}/dists/xa-${PKG_VERSION}.tar.gz"
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
