# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="batteryplus"
PKG_VERSION="1c31e89ec1828d51710ad35a607bdfad7e18464e"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Mikhailzrick/knubat.components"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="BatteryPlus is a battery percentage daemon for handheld Linux systems"
PKG_TOOLCHAIN="make"

pre_make_target() {
  cp ${PKG_DIR}/Makefile ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/batteryplus ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/sources/scripts/* ${INSTALL}/usr/bin

    mkdir -p ${INSTALL}/etc/batteryplus
      cp -a ${PKG_DIR}/config/batteryplus.conf ${INSTALL}/etc/batteryplus

    mkdir -p ${INSTALL}/etc/batteryplus/charging.d
      touch ${INSTALL}/etc/batteryplus/charging.d/.keep

    mkdir -p ${INSTALL}/etc/batteryplus/discharging.d
      touch ${INSTALL}/etc/batteryplus/discharging.d/.keep

    mkdir -p ${INSTALL}/etc/batteryplus/state.d
      touch ${INSTALL}/etc/batteryplus/state.d/.keep
}

post_install() {
  enable_service batteryplus.service
}
