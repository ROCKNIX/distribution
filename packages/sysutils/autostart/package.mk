# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="autostart"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="Autostart is a systemd helper that starts/configures device specific services and parameters."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/autostart ${INSTALL}/usr/bin
  if [ -d ${PKG_DIR}/sources/common ]
  then
    mkdir -p ${INSTALL}/usr/lib/autostart/common
    cp ${PKG_DIR}/sources/common/* ${INSTALL}/usr/lib/autostart/common
    chmod -R 0755 ${INSTALL}/usr/lib/autostart/common
  fi
  if [ -d "${PKG_DIR}/sources/daemons" ]
  then
    mkdir -p ${INSTALL}/usr/lib/autostart/daemons
    cp ${PKG_DIR}/sources/daemons/* ${INSTALL}/usr/lib/autostart/daemons
    chmod -R 0755 ${INSTALL}/usr/lib/autostart/daemons
  fi
  chmod -R 0755 ${INSTALL}/usr/bin/autostart
}
