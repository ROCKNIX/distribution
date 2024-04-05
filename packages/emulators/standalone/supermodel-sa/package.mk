# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="supermodel-sa"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/DirtBagXon/model3emu-code-sinden"
PKG_ARCH="any"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="${OPENGL} ${OPENGLES} glu toolchain SDL2 SDL2_net zlib"
PKG_LONGDESC="Supermodel is a Sega Model 3 arcade emulator"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

case ${TARGET_ARCH} in
  aarch64|arm)
    PKG_VERSION="f94232e45e17f74ea510c7b754eec73529f06f58"
    PKG_GIT_CLONE_BRANCH="arm"
  ;;
  *)
    PKG_VERSION="f3f12a72c0e91e8e6bfabb1f1c6a039e926ac186"
    PKG_GIT_CLONE_BRANCH="main"
  ;;
esac

PKG_MAKE_OPTS="NET_BOARD=1"

pre_configure_target() {
  cp ${PKG_BUILD}/Makefiles/Makefile.UNIX ${PKG_BUILD}/Makefile

  # Add proper include directory
  sed -e "s+-DGLEW_STATIC+-I${SYSROOT_PREFIX}/usr/include -DGLEW_STATIC+g" -i ${PKG_BUILD}/Makefiles/Rules.inc

  # Fix to allow cross-compiling
  sed 's+ARCH = -march=native+ARCH = -DSDL_DISABLE_IMMINTRIN_H+g' -i ${PKG_BUILD}/Makefiles/Rules.inc

  # This file needs to be compiled for the Host system to run. Hard coding gcc for now.
  sed 's+$(SILENT)$(CC) $< $(CFLAGS)+$(SILENT)gcc $< $(CFLAGS) -march=native+g' -i ${PKG_BUILD}/Makefiles/Rules.inc
  sed 's+$(SILENT)$(LD) $(MUSASHI_LDFLAGS)+$(SILENT)gcc $(MUSASHI_LDFLAGS)+g' -i ${PKG_BUILD}/Makefiles/Rules.inc

  # More fixes for cross compilation.
  sed 's+CC = gcc+ +g' -i ${PKG_BUILD}/Makefile
  sed 's/CXX = g++/ /g' -i ${PKG_BUILD}/Makefile
  sed 's+LD = gcc+ +g' -i ${PKG_BUILD}/Makefile

  # Use the compiler to link vs ld as the original Makefile intended and cross compiler fixes above changed.
  sed 's+$(SILENT)$(LD) $(OBJ_FILES) $(LDFLAGS)+$(SILENT)$(CC) $(OBJ_FILES) $(LDFLAGS)+g' -i ${PKG_BUILD}/Makefiles/Rules.inc
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -a ${PKG_BUILD}/bin/supermodel ${INSTALL}/usr/bin/supermodel
  cp -a ${PKG_DIR}/scripts/start_supermodel.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/start_supermodel.sh
  mkdir -p ${INSTALL}/usr/config/supermodel
  mkdir -p ${INSTALL}/usr/config/supermodel/Config
  cp ${PKG_BUILD}/Config/Games.xml ${INSTALL}/usr/config/supermodel/Config
  cp ${PKG_BUILD}/Config/Supermodel.ini ${INSTALL}/usr/config/supermodel/Config
}
