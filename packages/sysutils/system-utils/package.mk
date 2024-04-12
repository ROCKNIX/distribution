# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="system-utils"
PKG_VERSION=""
PKG_LICENSE="mix"
PKG_DEPENDS_TARGET="toolchain sleep"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Hardware button support scripts."
PKG_TOOLCHAIN="manual"

makeinstall_target() {

  mkdir -p ${INSTALL}/usr/lib/autostart/common
  cp ${PKG_DIR}/sources/autostart/common/* ${INSTALL}/usr/lib/autostart/common

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/fancontrol ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/headphone_sense ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/hdmi_sense ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/input_sense ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/bluetooth_sense ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/ledcontrol ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/scripts/turbomode ${INSTALL}/usr/bin
  if [ -d "${PKG_DIR}/sources/devices/${DEVICE}" ]
  then
    cp ${PKG_DIR}/sources/devices/${DEVICE}/* ${INSTALL}/usr/bin
    if [ -d "${PKG_DIR}/sources/autostart/${DEVICE}" ]
    then
      mkdir -p ${INSTALL}/usr/lib/autostart/${DEVICE}
      cp ${PKG_DIR}/sources/autostart/${DEVICE}/* ${INSTALL}/usr/lib/autostart/${DEVICE}
      chmod 0755 ${INSTALL}/usr/lib/autostart/${DEVICE}/*
    fi
  fi
  chmod 0755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config
  cp ${PKG_DIR}/sources/config/fancontrol.conf ${INSTALL}/usr/config/fancontrol.conf.sample
}

