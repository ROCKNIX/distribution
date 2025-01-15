# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="theodore-lr"
PKG_VERSION="70cd7965abe607a28ab3cee5689ed433d8f41da3"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/Zlika/theodore"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A port of the Theodore emulator for the Thomson MO/TO system--a family of French 8-bit home computers--to libretro. This core emulates all of the main models of the MO/TO family, including the TO7, TO7/70, TO8, TO8D, TO9, TO9+, MO5 and MO6 models, as well as the Olivetti Prodest PC128, which is a rebranded MO6 that was released in the Italian market. The core includes an onscreen keyboard, which can be toggled with retropad-select and navigated using the d-pad and retropad-B to press the selected key."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-C . platform=unix"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/theodore_libretro.so ${INSTALL}/usr/lib/libretro
}
