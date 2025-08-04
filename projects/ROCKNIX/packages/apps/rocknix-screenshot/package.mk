# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-screenshot"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain grim jq sway"
PKG_LONGDESC="ROCNIX screenshot utility"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/sources/rocknix-screenshot ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/rocknix-screenshot
}
