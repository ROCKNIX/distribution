# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="speedtest-cli"
PKG_VERSION="v2.1.3"
PKG_SHA256="45e3ca21c3ce3c339646100de18db8a26a27d240c29f1c9e07b6c13995a969be"
PKG_LICENSE="Apache License 2.0"
PKG_SITE="https://github.com/sivel/speedtest-cli"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Command line interface for testing internet bandwidth using speedtest.net"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/speedtest.py ${INSTALL}/usr/bin/speedtest-cli
  chmod +x ${INSTALL}/usr/bin/speedtest-cli
}
