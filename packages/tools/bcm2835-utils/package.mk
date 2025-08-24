# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bcm2835-utils"
PKG_VERSION="b7651d86d71a172b2208c67b2e360cbcb4f9d98f"
PKG_SHA256="d96de4b95f3cd69a9f14000802e05ee364b3be7ebee45c988ff5b7ee38b0acb1"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/raspberrypi/utils"
PKG_URL="https://github.com/raspberrypi/utils/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="cmake:host gcc:host dtc"
PKG_LONGDESC="Raspberry Pi related collection of scripts and simple applications"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -PRv ${PKG_BUILD}/.${TARGET_NAME}/vclog/vclog ${INSTALL}/usr/bin
  cp -PRv ${PKG_BUILD}/.${TARGET_NAME}/dtmerge/{dtoverlay,dtmerge,dtparam} ${INSTALL}/usr/bin
  cp -PRv ${PKG_BUILD}/.${TARGET_NAME}/pinctrl/pinctrl ${INSTALL}/usr/bin
  cp -PRv ${PKG_BUILD}/.${TARGET_NAME}/vcgencmd/vcgencmd ${INSTALL}/usr/bin
  cp -PRv ${PKG_BUILD}/.${TARGET_NAME}/vcmailbox/vcmailbox ${INSTALL}/usr/bin
}
