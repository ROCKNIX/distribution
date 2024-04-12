# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2023-present Daedalia (https://github.com/daedalia)

PKG_NAME="bsnes-hd-lr"
PKG_VERSION="f46b6d6368ea93943a30b5d4e79e8ed51c2da5e8"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/DerKoun/bsnes-hd"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="bsnes-hd is a fork of bsnes that adds HD video features such as widescreen, HD Mode 7 and true color"

PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET+=" -C bsnes target=libretro compiler=${TARGET_NAME}-g++"

pre_configure_target() {
  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/bsnes/GNUmakefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp bsnes/out/bsnes_hd_beta_libretro.so ${INSTALL}/usr/lib/libretro/
}

