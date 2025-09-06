# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gamepadcalibration"
PKG_VERSION="2077e7af7e9a8c1df54af6f1959cb92daea03207"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/cdeletre/GPcal"
PKG_URL="https://github.com/cdeletre/GPcal/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="Python3 SDL2 gamecontrollerdb"
PKG_LONGDESC="A gamepad calibration tool for the Retroid Pocket 5 and Mini"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/local/share

  tar -xzf ${PKG_BUILD}/rocknix/gpcal-python-3.13.tgz -C ${INSTALL}/usr/local/share
  chmod 0755 ${INSTALL}/usr/local/share/gpcal/main.py

  mkdir -p ${INSTALL}/usr/config/modules
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/*
}