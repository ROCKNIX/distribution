# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="m8c"
PKG_VERSION="v1.7.8"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/laamaa/m8c"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libserialport"
PKG_LONGDESC="Cross-platform M8 tracker headless client"
PKG_TOOLCHAIN="cmake"

makeinstall_target(){
  # Create directories
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/m8c
  mkdir -p ${INSTALL}/usr/config/modules

  cp -f m8c ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/m8c

  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/*

  if [ -d ${PKG_DIR}/config/${DEVICE} ]
  then
    cp -ra ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/m8c/
  fi
}
