# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="quirks"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain autostart ioport ectool"
PKG_LONGDESC="Quirks is a simple package that provides device quirks."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/autostart/quirks/{platforms,devices}
  cp -r ${PKG_DIR}/devices/* ${INSTALL}/usr/lib/autostart/quirks/devices
  if [ -d "${PKG_DIR}/platforms/${DEVICE}" ]
  then
    cp -r ${PKG_DIR}/platforms/* ${INSTALL}/usr/lib/autostart/quirks/platforms
  fi
  chmod -R 0755 ${INSTALL}/usr/lib/autostart/quirks
}

post_install() {
  enable_service led-poweroff.service
}
