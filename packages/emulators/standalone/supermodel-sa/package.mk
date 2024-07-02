# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="supermodel-sa"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/DirtBagXon/model3emu-code-sinden"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="${OPENGL} ${OPENGLES} glu toolchain SDL2 SDL2_net zlib"
PKG_LONGDESC="Supermodel is a Sega Model 3 arcade emulator"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

case ${TARGET_ARCH} in
  aarch64|arm)
    PKG_VERSION="cec451f3c3639622a372e0140ce3589ca616c84f"
    PKG_GIT_CLONE_BRANCH="arm"
  ;;
  *)
    PKG_VERSION="f3f12a72c0e91e8e6bfabb1f1c6a039e926ac186"
    PKG_GIT_CLONE_BRANCH="main"
  ;;
esac

PKG_MAKE_OPTS="NET_BOARD=1"

pre_patch() {
  cp ${PKG_BUILD}/Makefiles/Makefile.UNIX ${PKG_BUILD}/Makefile
}

post_patch() {
  # Add proper include directory
  sed -e "s+MUSASHI_CFLAGS =+MUSASHI_CFLAGS = -I${SYSROOT_PREFIX}/usr/include+g" -i ${PKG_BUILD}/Makefiles/Rules.inc
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -a ${PKG_BUILD}/bin/supermodel ${INSTALL}/usr/bin/supermodel
  cp -a ${PKG_DIR}/scripts/start_supermodel.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/start_supermodel.sh
  mkdir -p ${INSTALL}/usr/config/supermodel
  mkdir -p ${INSTALL}/usr/config/supermodel/Config
  cp ${PKG_BUILD}/Config/Games.xml ${INSTALL}/usr/config/supermodel/Config
  cp -r ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/supermodel/Config
}
