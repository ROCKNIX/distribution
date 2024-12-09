# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="es-theme-knulli"
PKG_VERSION="8cfabf681dfdfae117e02257310ce76a8198ac14"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/symbuzzer/es-theme-knulli"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="es-theme-knulli"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/themes/${PKG_NAME}
  cp -rf * ${INSTALL}/usr/share/themes/${PKG_NAME}
}

