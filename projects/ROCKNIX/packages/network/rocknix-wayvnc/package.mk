# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present UzuCore (https://github.com/UzuCore)

PKG_NAME="rocknix-wayvnc"
PKG_VERSION="1.0"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain wayvnc"
PKG_LONGDESC="Secure, SSH-only WayVNC service for ROCKNIX"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/rocknix-wayvnc ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/rocknix-wayvnc
}

post_install() {
  enable_service rocknix-wayvnc.service
}
