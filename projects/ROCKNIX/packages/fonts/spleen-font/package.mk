# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="spleen-font"
PKG_VERSION="2.0.0"
PKG_SHA256="778778b35dd48701b803db247a6ac8759154ce5fc3abd5cc0b6db98a44ba5a0c"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/fcambus/spleen"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/spleen-${PKG_VERSION}.tar.gz"

PKG_DEPENDS_INIT="toolchain bdf2psf:host"
PKG_DEPENDS_TARGET="toolchain bdf2psf:host"
PKG_LONGDESC="This package contains the Spleen Font"
PKG_TOOLCHAIN="manual"

pre_configure_init() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}-${TARGET}
}

pre_configure_target() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}-${TARGET}
}

configure_init() {
  :
}

configure_target() {
  :
}

make_init() {
  for font in spleen-5x8 spleen-6x12
  do
    ${TOOLCHAIN}/usr/bin/bdf2psf --fb \
            ${font}.bdf \
            ${TOOLCHAIN}/usr/share/bdf2psf/standard.equivalents \
            ${TOOLCHAIN}/usr/share/bdf2psf/ascii.set+${TOOLCHAIN}/usr/share/bdf2psf/linux.set+${TOOLCHAIN}/usr/share/bdf2psf/useful.set 512 \
            ${font}.psfu
  done
}

make_target() {
  make_init
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/share/consolefonts
  cp -rf *.bdf ${INSTALL}/usr/share/consolefonts
  cp -rf *.psfu ${INSTALL}/usr/share/consolefonts
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/consolefonts
  cp -rf ${PKG_BUILD}/*.bdf ${INSTALL}/usr/share/consolefonts
  cp -rf ${PKG_BUILD}/*.psfu ${INSTALL}/usr/share/consolefonts
}
