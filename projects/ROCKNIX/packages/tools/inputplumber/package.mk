# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="inputplumber"
PKG_VERSION="v0.73.0"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ShadowBlip/InputPlumber"
PKG_URL="https://github.com/ShadowBlip/InputPlumber/releases/download/${PKG_VERSION}/inputplumber-aarch64.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd libevdev libiio polkit"
PKG_LONGDESC="Open source input router and remapper daemon for Linux"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr
  rsync -ar ${PKG_BUILD}/usr/ ${INSTALL}/usr/
}

post_install() {
  enable_service inputplumber.service
}
