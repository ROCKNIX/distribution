# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="supermodel-sa"
PKG_VERSION="b13fdd5029a246e8f90a1d70e2ed000779fee4f1"
PKG_SHA256="ff4a925fdf739da08b4e8dd19e09d0a81dda0801fe2d276acf7905073bfa8b96"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/DirtBagXon/model3emu-code-sinden"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="${OPENGL} ${OPENGLES} glu toolchain SDL2 SDL2_net zlib"
PKG_LONGDESC="Supermodel is a Sega Model 3 arcade emulator"

PKG_MAKE_OPTS_TARGET="NET_BOARD=1"

post_unpack() {
  cp ${PKG_BUILD}/Makefiles/Makefile.UNIX ${PKG_BUILD}/Makefile
  sed -e "s+MUSASHI_CFLAGS =+MUSASHI_CFLAGS = -I${SYSROOT_PREFIX}/usr/include+g" -i ${PKG_BUILD}/Makefiles/Rules.inc
  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/bin/supermodel ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_supermodel.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/supermodel/Config
    cp -a ${PKG_BUILD}/Config/Games.xml ${INSTALL}/usr/config/supermodel/Config
    cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/supermodel/Config
}
